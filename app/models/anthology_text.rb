class AnthTextValidator < ActiveModel::Validator
  def validate(record)
    if record.manifestation_id.nil? # curated texts can always be added
      return true
    end
    if record.anthology.has_text?(record.manifestation_id, record.id)
      record.errors[:base] << I18n.t(:text_already_in_anthology)
    end
  end
end

class AnthologyText < ApplicationRecord
  validates_with AnthTextValidator
  belongs_to :anthology
  belongs_to :manifestation
  scope :is_text, -> { where.not(manifestation_id: nil) }
  scope :is_curated, -> { where(manifestation_id: nil) }

  def page_count
    begin
      if self.cached_page_count.nil? or self.updated_at < 30.days.ago
        if self.manifestation_id.nil?
          n = self.body.split.count/500.to_f
          self.cached_page_count = n.ceil
        else
          n = self.manifestation.word_count/500.to_f
          self.cached_page_count = n.ceil
        end 
        self.save
        self.touch # update updated_at even if the page count hasn't changed, otherwise we'll keep recalculating
      end
    rescue ActiveRecord::RecordInvalid
      # should only happen with already-invalid records, that were created before the uniqueness requirement. Ignore.
      puts $!
      nil
    end
    return self.cached_page_count
  end
  def render_html
    markdown = self.manifestation_id.nil? ? self.body : self.manifestation.markdown
    return MultiMarkdown.new(markdown).to_html.force_encoding('UTF-8').gsub(/<figcaption>.*?<\/figcaption>/,'') # remove MMD's automatic figcaptions
  end
end
