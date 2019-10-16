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

  def accessible?(user)
    return true if self.pub? or self.unlisted?
    return true if user == self.user
    return false
  end

  def ordered_texts
    ret = []
    unless self.texts.empty?
      seq = self.sequence.split(';')
      seq.each do |id|
        ret << self.texts.find(id)
      end
    end
    return ret
  end

  def update_sequence(text_id, old, new)
    seq = self.sequence.split(';')
    if old < new
      seq.insert(new+1, text_id)
      seq.delete_at(old)
    else
      seq.delete_at(old)
      seq.insert(new, text_id)
    end
    self.sequence = seq.join(';')
    self.save!
  end
end
