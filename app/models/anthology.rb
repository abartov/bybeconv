
class UserAnthTitleValidator < ActiveModel::Validator
  def validate(record)
    extra_cond = record.id.nil? ? '' : "and id <> #{record.id}"
    unless record.user.anthologies.where("title = '#{record.title}' #{extra_cond}").empty?
      record.errors[:base] << I18n.t(:title_already_exists)
    end
  end
end

class Anthology < ApplicationRecord
  belongs_to :user
  has_many :texts, class_name: 'AnthologyText', :dependent => :delete_all
  enum access: %i(priv unlisted pub)
  validates :title, presence: true
  validates_with UserAnthTitleValidator

  def has_text?(text_id, anth_text_id = nil)
    if anth_text_id.nil?
      return self.texts.where(manifestation_id: text_id).present?
    else
      return self.texts.where("manifestation_id = #{text_id} and id <> #{anth_text_id}").present?
    end
  end

  def page_count(force_update = false)
    if self.cached_page_count.nil? or self.updated_at < 30.days.ago or force_update
      count = 0
      texts.each do |at|
        count += at.page_count
      end
      self.cached_page_count = count
      self.save
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
        begin
          ret << self.texts.find(id)
        rescue
        end
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

  def append_to_sequence(text_id)
    if self.sequence.nil? or self.sequence.empty?
      self.sequence = ''
    else
      self.sequence += ';'
    end
    self.sequence += text_id.to_s
    self.save!
    page_count(true) # force update
  end

  def remove_from_sequence(text_id)
    return if self.sequence.nil? or self.sequence.empty?
    seq = self.sequence.split(';')
    seq.delete(text_id)
    self.sequence = seq.join(';')
    self.save!
  end
end
