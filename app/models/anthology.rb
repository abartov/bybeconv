
class UserAnthTitleValidator < ActiveModel::Validator
  def validate(record)
    records = record.user.anthologies.where(title: record.title)
    unless record.new_record?
      records = records.where('id <> ?', record.id)
    end
    unless records.empty?
      record.errors.add(:title, I18n.t(:title_already_exists))
    end
  end
end

# Anthology is a User-managed collection of texts. Each user can create own anthologies
class Anthology < ApplicationRecord
  include TrackingEvents

  belongs_to :user
  has_many :texts, class_name: 'AnthologyText', dependent: :destroy
  has_many :downloadables, as: :object, dependent: :destroy
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings, class_name: 'Tag'
  enum :access, { priv: 0, unlisted: 1, pub: 2 }
  validates :title, presence: true
  validates_with UserAnthTitleValidator

  # this will return the downloadable entity for the Anthology *if* it is fresh
  def fresh_downloadable_for(doctype)
    dl = downloadables.where(doctype: doctype).first
    return nil if dl.nil?
    return nil unless dl.stored_file.attached? # invalid downloadable without file
    return nil if dl.updated_at < self.updated_at # needs to be re-generated
    # also ensure none of the *included* texts is fresher than the saved downloadable
    self.texts.where.not(manifestation_id: nil).each do |at|
      return nil if dl.updated_at < at.manifestation.updated_at
    end
    return dl
  end

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
          ret << self.texts.select{|x| x.id == id.to_i}.first
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
