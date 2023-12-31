class Expression < ApplicationRecord
  before_save :set_translation
  before_save :norm_dates
  enum period: %i(ancient medieval enlightenment revival modern)

  belongs_to :work, inverse_of: :expressions
  has_many :manifestations, inverse_of: :expression, dependent: :destroy
  has_many :realizers, dependent: :destroy
  has_many :persons, through: :realizers, class_name: 'Person'
  has_many :involved_authorities, as: :item, dependent: :destroy
  has_many :aboutnesses, as: :aboutable, dependent: :destroy
  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings, class_name: 'Tag'
  has_paper_trail # for monitoring crowdsourced inputs

  def editors
    return realizers.includes(:person).where(role: Realizer.roles[:editor]).map{|x| x.person}
  end

  def translators
    return realizers.includes(:person).where(role: Realizer.roles[:translator]).map {|x| x.person}
  end

  def self.cached_translations_count
    Rails.cache.fetch("e_translations", expires_in: 24.hours) do
      Expression.where(translation: true).count
    end
  end

  # Returns total count of published works by each period
  # @return hash where keys are period names and value is a number of works from the given period
  def self.cached_work_count_by_periods
    Rails.cache.fetch("e_works_by_periods", expires_in: 24.hours) do
      Expression.joins(:manifestations).merge(Manifestation.all_published).group(:period).count
    end
  end

  protected

  def set_translation
    self.translation = language != work.orig_lang
    return true
  end

  def norm_dates
    nd = normalize_date(self.date)
    self.normalized_pub_date = nd unless nd.nil?
  end
end
