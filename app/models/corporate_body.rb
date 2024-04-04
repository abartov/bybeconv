class CorporateBody < ApplicationRecord
  include Authority
  enum status: %i(published unpublished deprecated awaiting_first)

  has_many :involved_authorities, class_name: 'InvolvedAuthority', as: :authority, dependent: :destroy
  has_many :works, through: :involved_authorities, class_name: 'Work'
  has_many :expressions, through: :involved_authorities, class_name: 'Expression'
  # has_many :publications, dependent: :destroy
  has_many :aboutnesses, as: :aboutable, dependent: :destroy
  has_many :external_links, as: :linkable, dependent: :destroy
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings, class_name: 'Tag'

  has_one_attached :profile_image

  validates_presence_of :name, :status

  def cached_latest_stuff
    Rails.cache.fetch("cb_#{self.id}_latest_stuff", expires_in: 24.hours) do
      latest_stuff
    end
  end

  def cached_original_works_by_genre
    Rails.cache.fetch("cb_#{self.id}_original_works_by_genre", expires_in: 24.hours) do
      original_works_by_genre
    end
  end

  def cached_translations_by_genre
    Rails.cache.fetch("cb_#{self.id}_translations_by_genre", expires_in: 24.hours) do
      translations_by_genre
    end
  end

  def cached_works_count
    Rails.cache.fetch("cb_#{self.id}_work_count", expires_in: 24.hours) do
      authority_works_count
    end
  end

  def life_years # convenience method to save an if when treating Authorities
    return "#{inception_year}&rlm;-#{dissolution_year}"
  end

  def image_url
    rails_blob_url(profile_image)
  end

  def gender_letter
    return 'ו'
  end
end
