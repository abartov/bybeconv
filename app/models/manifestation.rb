include BybeUtils
class Manifestation < ApplicationRecord
  # is_impressionable :counter_cache => true # for statistics
  is_impressionable # :counter_cache => true # for statistics
  include CompactedImpressions
  paginates_per 100
  belongs_to :expression, inverse_of: :manifestations
  has_and_belongs_to_many :html_files
  has_and_belongs_to_many :likers, join_table: :work_likes, class_name: :User

  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings, class_name: 'Tag'

  has_many :recommendations, dependent: :destroy
  has_many :bookmarks, dependent: :destroy

  has_many :list_items, as: :item, dependent: :destroy
  has_many :downloadables, as: :object, dependent: :destroy

  has_paper_trail ignore: %i(impressions_count created_at updated_at)
  has_many :external_links, as: :linkable, dependent: :destroy
  has_many :proofs, dependent: :destroy
  has_many :anthology_texts, dependent: :destroy
  has_many_attached :images, dependent: :destroy
  has_many :collection_items, as: :item
  before_save :update_sort_title!

  enum status: { published: 0, nonpd: 1, unpublished: 2, deprecated: 3 }

  scope :all_published, -> { where(status: Manifestation.statuses[:published]) }
  scope :new_since, ->(since) { where('created_at > ?', since) }
  scope :not_translations, -> { joins(:expression).includes(:expression).where(expressions: { translation: false }) }
  scope :translations, -> { joins(:expression).includes(:expression).where(expressions: { translation: true }) }
  scope :genre, ->(genre) { joins(expression: :work).where(works: { genre: genre }) }
  scope :tagged_with, lambda { |tag_id|
                        joins(:taggings).where(taggings: { tag_id: tag_id, status: Tagging.statuses[:approved] }).distinct
                      }
  scope :with_involved_authorities, lambda {
    preload(expression: { involved_authorities: :authority, work: { involved_authorities: :authority } })
  }

  SHORT_LENGTH = 1500 # kind of arbitrary...
  LONG_LENGTH = 15_000 # kind of arbitrary...

  update_index('manifestations') { self } # update ManifestationsIndex when entity is updated

  def involved_authorities
    (expression.involved_authorities + expression.work.involved_authorities).uniq
  end

  def involved_authorities_by_role(role)
    (expression.involved_authorities_by_role(role) + expression.work.involved_authorities_by_role(role)).uniq
                                                                                                        .sort_by(&:name)
  end

  def update_sort_title
    return if changed.include?('sort_title')

    self.sort_title = title.strip_nikkud.tr('[]()*"\'', '').tr('-־', ' ').strip
    self.sort_title = ::Regexp.last_match.post_match if sort_title =~ /^\d+\. /
  end

  def like_count
    return likers.count
  end

  def video_count
    return external_links.status_approved.linktype_youtube.count
  end

  # this will return the downloadable entity for the Manifestation *if* it is fresh
  def fresh_downloadable_for(doctype)
    dl = downloadables.where(doctype: doctype).first
    return nil if dl.nil?
    return nil if dl.updated_at < updated_at # needs to be re-generated

    return dl
  end

  def long?
    markdown.length > LONG_LENGTH
  end

  def not_short?
    markdown.length > SHORT_LENGTH
  end

  def heading_lines
    if cached_heading_lines.nil?
      recalc_heading_lines!
    end
    cached_heading_lines.split('|').map { |line| line.to_i }
  end

  def chapters?
    return false if cached_heading_lines.nil? || cached_heading_lines.empty? || cached_heading_lines[1..5].index('|').nil?

    return true
  end

  def recalc_heading_lines
    lines = markdown.lines
    temp_heading_lines = []
    lines.each_index { |i| temp_heading_lines << i if lines[i][0..1] == '##' && lines[i][2] != '#' }
    self.cached_heading_lines = temp_heading_lines.join('|')
  end

  def recalc_heading_lines!
    recalc_heading_lines
    save!
  end

  def approved_tags
    taggings.to_a.select { |t| t.approved? && t.tag.approved? }.map(&:tag)
  end

  def as_prose?
    # TODO: implement more generically
    return %w(poetry drama).include?(expression.work.genre) ? false : true
  end

  def safe_filename
    # Use manifestation id as a filename to prevent issues with long filename described here
    # https://github.com/abartov/bybeconv/issues/101#issuecomment-1002994205
    id.to_s
  end

  def to_plaintext
    return html2txt(MultiMarkdown.new(markdown).to_html.force_encoding('UTF-8').gsub(%r{<figcaption>.*?</figcaption>}, '')).gsub("\n\n\n", "\n\n").gsub(
      "\n\n\n", "\n\n"
    )
  end

  # return containing collections of collectin_type volume or periodical_issue
  def volumes
    ret = []
    containers = collection_items.includes(:collection).map(&:collection)
    containers.each do |c|
      if %w(volume periodical_issue).include?(c.collection_type)
        ret << c
      else
        pc = c.parent_volume_or_isssue
        ret << pc unless pc.nil?
      end
    end
    return ret.flatten
  end

  def to_html
    published? ? MultiMarkdown.new(markdown).to_html.force_encoding('UTF-8').gsub(%r{<figcaption>.*?</figcaption>}, '') : t(:not_public_yet)
  end

  def title_and_authors
    return title + ' / ' + author_string
  end

  def title_and_authors_html
    ret = "<h1>#{title}</h1> <h2>#{I18n.t(:by)} #{authors_string}</h2> "
    if expression.translation?
      ret += "<h2>#{I18n.t(:translated_from)}#{textify_lang(expression.work.orig_lang)} #{I18n.t(:by)} #{translators_string}</h2>"
    end
    return ret
  end

  def manual_delete
    destroy!
    expression.involved_authorities.each(&:destroy!)
    w = expression.work
    expression.destroy!
    w.involved_authorities.each(&:destroy!)
    w.destroy!
  end

  def snippet_paragraphs(p_count)
    return MultiMarkdown.new(markdown.lines[0..p_count].join("\n")).to_html.force_encoding('UTF-8').gsub(%r{<h1.*?</h1>}, '').gsub(%r{<figcaption>.*?</figcaption>}, '') # remove MMD's automatic figcaptions, and the initial title
    # stripping tags -- return ActionController::Base.helpers.strip_tags(MultiMarkdown.new(markdown.lines[0..p_count].join("\n")).to_html.force_encoding('UTF-8').gsub(/<h1.*?<\/h1>/,'').gsub(/<figcaption>.*?<\/figcaption>/,'')) # remove MMD's automatic figcaptions, and the initial title
  end

  def authors_string
    return I18n.t(:nil) if expression.work.authors.empty?

    return expression.work.authors.map(&:name).join(', ')
  end

  def first_hebrew_letter
    ret = '*'
    title.each_char { |ch| return ch if title.is_hebrew_codepoint_utf8(ch.codepoints[0]) }
    return ret
  end

  def authors
    return expression.work.authors
  end

  def author_gender
    authors.map { |authority| authority&.person&.gender }.compact.uniq
  end

  def translator_gender
    translators.map { |authority| authority&.person&.gender }.compact.uniq
  end

  def translators
    return expression.translators
  end

  def author_and_translator_ids
    ret = []
    au = authors
    au = [] if au.nil?
    tra = translators
    tra = [] if tra.nil?
    ret = au.pluck(:id) + tra.pluck(:id)
    return ret.uniq
  end

  def translators_string
    return I18n.t(:nil) if expression.translators.empty?

    return expression.translators.map(&:name).join(', ')
  end

  def author_string
    Rails.cache.fetch("m_#{id}_author_string", expires_in: 24.hours) do
      author_string!
    end
  end

  def author_string!
    return I18n.t(:nil) if expression.work.authors.empty?

    ret = expression.work.authors.map(&:name).join(', ')
    if expression.translation
      ret += if translators.empty?
               ' / ' + I18n.t(:unknown)
             else
               ' / ' + translators.map(&:name).join(', ')
             end
    end
    ret # TODO: be less naive
  end

  def legacy_htmlfile
    hh = HtmlFile.joins(:manifestations).where(manifestations: { id: id })
    return nil if hh.empty?

    return hh[0]
  end

  def markdown_with_metadata
    metadata = "Title: #{title}  \nAuthor: #{author_string}  \n\n"
    return metadata + markdown
  end

  def word_count
    # roughly okay, despite the markdown artifacts
    return markdown.split.length
  end

  def recalc_cached_people
    # pp = []
    # expression.persons.each {|p| pp << p unless pp.include?(p) }
    # expression.work.persons.each {|p| pp << p unless pp.include?(p) }
    # self.cached_people = pp.map{|p| "#{p.name} #{p.other_designation}"}.join('; ') # ZZZ
    self.cached_people = author_string!
    # self.cached_people_ids = pp.map{|x| x.id}.join() # this doesn't actually make sense; a normalized query would be way faster
  end

  def recalc_cached_people!
    recalc_cached_people
    save!
  end

  # TODO: calculate this by month
  def self.popular_works_by_genre(genre, xlat)
    if xlat
      Rails.cache.fetch("m_pop_xlat_in_#{genre}", expires_in: 24.hours) do # memoize
        Manifestation.all_published.joins(expression: :work).includes(:expression).where(works: { genre: genre }).where('works.orig_lang != expressions.language').order(impressions_count: :desc).limit(10).map do |m|
          { id: m.id, title: m.title, author: m.author_string }
        end
      end
    else
      Rails.cache.fetch("m_pop_in_#{genre}", expires_in: 24.hours) do # memoize
        Manifestation.all_published.joins(expression: :work).where(works: { genre: genre }).where('works.orig_lang = expressions.language').order(impressions_count: :desc).limit(10).map do |m|
          { id: m.id, title: m.title, author: m.author_string }
        end
      end
    end
  end

  def self.add_publisher_link_to_works(worklist, url, linktext)
    el = ExternalLink.new(linktype: :publisher_site, url: url, description: linktext)
    works = Manifestation.find(worklist)
    works.each do |m|
      newel = el.dup
      m.external_links << newel
      m.save!
    end
  end

  def self.randomize_in_genre_except(except, genre)
    list = []
    i = 0
    begin
      candidates = Manifestation.all_published.genre(genre).order('RAND()').limit(15)
      candidates.each { |au| list << au unless (except.include? au) or (list.include? au) or (list.length == 10) }
      i += 1
    end until list.size >= 10 or i > 10
    return list
  end

  def self.first_25
    Rails.cache.fetch('m_first_25', expires_in: 24.hours) do
      Manifestation.all_published.order(:sort_title).limit(25)
    end
  end

  def self.cached_popular_works_by_genre
    Rails.cache.fetch('m_pop_by_genre', expires_in: 24.hours) do
      ret = {}
      get_genres.each do |g|
        ret[g] = {}
        ret[g][:orig] =
          Manifestation.all_published.genre(g).not_translations.distinct.order(impressions_count: :desc).limit(10)
        ret[g][:xlat] =
          Manifestation.all_published.genre(g).translations.distinct.order(impressions_count: :desc).limit(10)
      end
      ret
    end
  end

  def self.cached_count
    Rails.cache.fetch('m_count', expires_in: 24.hours) do
      Manifestation.all_published.count
    end
  end

  def self.cached_work_counts_by_genre
    Rails.cache.fetch('m_count_by_genre', expires_in: 24.hours) do
      ret = {}
      get_genres.each do |g|
        ret[g] = Manifestation.all_published.genre(g).distinct.count
      end
      ret
    end
  end

  def self.cached_translated_count
    Rails.cache.fetch('m_xlat_count', expires_in: 24.hours) do
      Manifestation.all_published.translations.count
    end
  end

  def self.cached_pd_count
    Rails.cache.fetch('m_pd_count', expires_in: 24.hours) do
      Manifestation.all_published.pd.count
    end
  end

  def self.get_popular_works
    Rails.cache.fetch('m_popular_works', expires_in: 48.hours) do
      evs = Ahoy::Event.where(name: 'text read or printed').where('time > ?', 1.month.ago)
      pop = {}
      evs.each do |x|
        mid = x.properties['text_id']
        pop[mid] = 0 unless pop[mid].present?
        pop[mid] += 1
      end
      sorted_pop_keys = pop.keys.sort_by { |k| pop[k] }.reverse
      Manifestation.find(sorted_pop_keys[0..9])
    end
  end

  def self.update_suspected_typos_list
    # TODO: implement
    # code to find probable typos:
    # - digits within words
    # - finals within words
    # - non-final letters that should be finals
    # - non-title paragraphs ending without period, question mark, exclamation point.
    # - what else?
  end
end
