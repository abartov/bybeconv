class AnthologyText < ApplicationRecord
  belongs_to :anthology
  belongs_to :manifestation
  scope :is_text, -> { where.not(manifestation_id: nil) }
  scope :is_curated, -> { where(manifestation_id: nil) }

  def page_count
    if self.cached_page_count.nil? or self.updated_at > 30.days.ago
      if self.manifestation_id.nil?
        n = self.body.split.count/500.to_f
        self.cached_page_count = n.ceil
      else
        n = self.manifestation.word_count/500.to_f
        self.cached_page_count = n.ceil
      end
      self.save!
    end
    return self.cached_page_count
  end

  def render_html
    markdown = self.manifestation_id.nil? ? self.body : self.manifestation.markdown
    return MultiMarkdown.new(markdown).to_html.force_encoding('UTF-8').gsub(/<figcaption>.*?<\/figcaption>/,'') # remove MMD's automatic figcaptions
  end
end
