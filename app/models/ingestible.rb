# frozen_string_literal: true

require 'pandoc-ruby' # for generic DOCX-to-HTML conversions

# Ingestible is a set of text being prepared for inclusion into a main database
class Ingestible < ApplicationRecord
  LOCK_TIMEOUT_IN_SECONDS = 60 * 15 # 15 minutes

  enum status: { draft: 0, ingested: 1, failed: 2, awaiting_authorities: 3 }
  enum scenario: { single: 0, multiple: 1, mixed: 2 }

  belongs_to :user
  belongs_to :locked_by_user, class_name: 'User', optional: true
  belongs_to :volume, optional: true, class_name: 'Collection'

  DEFAULTS_SCHEMA = {}.freeze
  validates :title, presence: true
  validates :status, presence: true
  validates :locked_at, presence: true, if: -> { locked_by_user.present? }
  validates :locked_at, absence: true, unless: -> { locked_by_user.present? }
  validate :volume_decision
#  validates :scenario, presence: true
#  validates :scenario, inclusion: { in: scenarios.keys }

  has_one_attached :docx # ActiveStorage

  before_save :update_timestamps
  before_create :init_timestamps

  # after_commit :update_parsing # this results in ActiveStorage::FileNotFoundError in dev/local storage

  before_save do
    if @texts.present?
      self.works_buffer = @texts.map(&:to_hash).to_json
    end
  end

  def volume_decision
    return if no_volume

    return unless volume_id.blank? && prospective_volume_id.blank? && prospective_volume_title.blank?

    errors.add(:volume_id,
               'must be present if no_volume is false')
  end

  def encode_toc(lines)
    return lines.map { |x| x.join('||') }.join("\n")
  end

  def decode_toc
    return [] unless toc_buffer.present?

    return toc_buffer.lines.map(&:strip).reject(&:empty?).map { |x| x.split('||').map(&:strip) }
  end

  def texts_to_upload
    return decode_toc.select { |x| x[0].strip == 'yes' }
  end

  def placeholders
    return decode_toc.select { |x| x[0].strip == 'no' }
  end

  def multiple_works?
    return markdown =~ /^&&& / # the magic marker for a new work
  end

  def init_timestamps
    self.markdown_updated_at = Time.zone.now
    self.works_buffer_updated_at = Time.zone.now
  end

  def update_timestamps
    return unless markdown_changed?

    self.markdown_updated_at = Time.zone.now
  end

  def update_parsing
    if docx.attached? && (markdown.blank? || docx.attachment.created_at > markdown_updated_at)
      self.markdown = convert_to_markdown
    end

    update_buffers if markdown_updated_at > works_buffer_updated_at
    save if changed?
  end

  def update_authorities_and_metadata_from_volume
    # reset *default* authorities and metadata on any volume change, to avoid accidental carryover
    self.default_authorities = ''
    self.publisher = ''
    self.year_published = ''
    aus = []
    seqno = 1
    if volume_id.present?
      volume = Collection.find(volume_id)
      volume.involved_authorities.each do |ia|
        aus << { seqno: seqno, authority_id: ia.authority.id, authority_name: ia.authority.name, role: ia.role }
        seqno += 1
      end
      self.publisher = volume.publisher_line
      self.year_published = volume.pub_year
    elsif prospective_volume_id.present?
      if prospective_volume_id[0] == 'P'
        pub = Publication.find(prospective_volume_id[1..-1])
        self.publisher = pub.publisher_line
        self.year_published = pub.pub_year
        # populate with default role of author, though this would be false when the Hebrew author
        # is the translator of a foreign work. Such cases would need to be corrected manually.
        aus << { seqno: seqno, authority_id: pub.authority.id, authority_name: pub.authority.name, role: 'author' }
      else
        volume = Collection.find(prospective_volume_id)
        self.publisher = volume.publisher_line
        self.year_published = volume.pub_year
        volume.involved_authorities.each do |ia|
          aus << { seqno: seqno, authority_id: ia.authority.id, authority_name: ia.authority.name, role: ia.role }
          seqno += 1
        end
      end
    end
    return unless aus.present?
    self.default_authorities = aus.to_json
    save!
  end

  def convert_to_markdown
    return unless docx.attached?

    bin = docx.download # grab the docx binary
    tmpfile = Tempfile.new(['docx2mmd__', '.docx'], encoding: 'ascii-8bit')
    tmpfile_pp = Tempfile.new(['docx2mmd__pp_', '.docx'], encoding: 'ascii-8bit')
    begin
      tmpfile.write(bin)
      tmpfile.flush
      tmpfilename = tmpfile.path
      # preserve linebreaks to post-process after Pandoc!
      doc = Docx::Document.open(tmpfilename)
      doc.paragraphs.each do |p|
        p.text = '&&STANZA&&' if p.text.empty? # replaced with <br> tags in postprocess
      end
      doc.save(tmpfile_pp.path) # save modified version

      # limit memory use in production; otherwise severe server hangs possible
      mem_limit = Rails.env.development? ? '' : ' -M1200m '
      markdown = `pandoc +RTS #{mem_limit} -RTS -f docx -t markdown_mmd #{tmpfile_pp.path} 2>&1`
      raise 'Heap exhausted' if markdown =~ /pandoc: Heap exhausted/

      self.markdown_updated_at = Time.zone.now
      return postprocess(markdown)

    # docx too large for pandoc with mem_limit
    rescue StandardError
      raise 'Conversion error'
    ensure
      tmpfile.close
    end
  end

  # copied from HtmlFileController's new_postprocess
  def postprocess(buf)
    # join lines in <span> elements that, er, span more than one line
    buf.gsub!(%r{<span.*?>.*?\n.*?</span>}) { |thematch| thematch.sub("\n", ' ') }
    # remove all <span> tags because pandoc generates them excessively
    buf.gsub!(/<span.*?>/m, '')
    buf.gsub!('</span>', '')
    lines = buf.split("\n")
    in_footnotes = false
    prev_nikkud = false
    (0..lines.length - 1).each do |i|
      lines[i].strip!
      if lines[i].empty? && prev_nikkud
        lines[i] = '> '
        next
      end
      uniq_chars = lines[i].gsub(/[\s\u00a0]/, '').chars.uniq
      if (uniq_chars == ['*']) || (uniq_chars == ["\u2013"]) # if the line only contains asterisks/En-Dash (U+2013)
        lines[i] = '***' # make it a Markdown horizontal rule
        prev_nikkud = false
      else
        nikkud = is_full_nikkud(lines[i])
        # once reached the footnotes section, set the footnotes mode to properly handle multiline footnotes with tabs
        in_footnotes = true if lines[i] =~ /^\[\^\d+\]:/
        if nikkud
          # make full-nikkud lines PRE
          lines[i] = "> #{lines[i]}\n" unless lines[i] =~ /\[\^\d+/ # produce a blockquote (PRE ignores bold/markup)
          prev_nikkud = true
        else
          prev_nikkud = false
        end
        if in_footnotes && lines[i] !~ /^\[\^\d+\]:/ # add a tab for multiline footnotes
          lines[i] = "\t#{lines[i]}"
        end
      end
    end
    new_buffer = lines.join "\n"
    new_buffer.gsub!("\n\s*\n\s*\n", "\n\n")
    ['.', ',', ':', ';', '?', '!'].each do |c|
      new_buffer.gsub!(" #{c}", c) # remove spaces before punctuation
    end
    new_buffer.gsub!('©כל הזכויות', '© כל הזכויות') # fix an artifact of the conversion
    new_buffer.gsub!(/> (.*?)\n\s*\n\s*\n/, "> \\1\n\n<br>\n") # add <br> tags for poetry to preserve stanza breaks
    new_buffer.gsub!('&&STANZA&&', "\n> \n<br />\n> \n") # sigh
    new_buffer.gsub!('&amp;&amp;STANZA&amp;&amp;', "\n> \n<br />\n> \n") # sigh
    new_buffer.gsub!(%r{(\n\s*)*\n> \n<br />\n> (\n\s*)*}, "\n> \n<br />\n> \n\n") # sigh
    new_buffer.gsub!(/\n> *> +/, "\n> ") # we basically never want this super-large indented poetry
    new_buffer.gsub!(/\n\s*\n> *\n> /, "\n> \n> ") # remove extra newlines before verse lines
    new_buffer.gsub!('> <br />', '<br />') # remove PRE from line-break, which confuses the markdown processor
    return new_buffer
  end

  # split markdown into sections and populate or update the works_buffer
  def update_buffers
    return if markdown.blank?

    buf = if multiple_works?
            sections = markdown.split('&&& ')
            # this would skip the first match if no text appeared before the first &&&
            sections.map do |section|
              title = section.lines.first # may be nil - handle in view
              title.strip! if title.present?
              content = section.lines[1].nil? ? [] : section.lines[1..].map(&:strip)
              # the file may have multiple works but also some words (e.g. a dedication) before
              # the first work. This should be treated as text without a title, and is handled
              # later, in the works_buffers.
              if content.join.blank? && title.present?
                content = [title]
                title = nil
              end
              { title: title, content: content.join("\n") } if content.present?
            end.compact
          else
            [{ title: self.title, content: markdown }]
          end
    self.works_buffer = buf.to_json
    self.works_buffer_updated_at = Time.current
    save
  end

  def texts
    # TODO: invalidate memoized value
    @texts ||= works_buffer.nil? ? [] : JSON.parse(works_buffer).map { |json| IngestibleText.new(json) }
  end

  def locked?
    locked_at.present? && locked_at > LOCK_TIMEOUT_IN_SECONDS.seconds.ago
  end

  def obtain_lock(user)
    return false if locked? && locked_by_user_id != user.id

    # To avoid excessive updates we only refresh lock if more than 10 seconds passed since previous lock refresh
    if locked_at.nil? || locked_at < 10.seconds.ago
      update_columns(locked_at: Time.zone.now, locked_by_user_id: user.id) # we deliberately skip validations here # rubocop:disable Rails/SkipsModelValidations
    end

    return true
  end

  def release_lock
    update_columns(locked_at: nil, locked_by_user_id: nil) # we deliberately skip validations here # rubocop:disable Rails/SkipsModelValidations
  end
end
