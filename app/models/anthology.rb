class Anthology < ApplicationRecord
  belongs_to :user
  has_many :texts, class_name: 'AnthologyText'
  enum access: %i(priv unlisted pub)

  def page_count
    if self.cached_page_count.nil? or self.updated_at > 30.days.ago
      count = 0
      texts.each do |at|
        count += at.page_count
      end
      self.cached_page_count = count
      self.save!
    end
    return self.cached_page_count
  end
end
