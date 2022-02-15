class Expression < ApplicationRecord
  before_save :set_translation
  before_save :norm_dates
  enum period: %i(ancient medieval enlightenment revival modern)

  has_and_belongs_to_many :works
  has_and_belongs_to_many :manifestations
  has_many :realizers, dependent: :destroy
  has_many :persons, through: :realizers, class_name: 'Person'
  has_many :aboutnesses, as: :aboutable, dependent: :destroy

  validates_inclusion_of :genre, in: Work::GENRES

  def determine_is_translation?
    # determine whether this expression is a translation or not, i.e. is in a different language to the work it expresses
    return nil if works.empty?
    language != works[0].orig_lang # TODO: handle multiple works?
  end

  def editors
    return realizers.includes(:person).where(role: Realizer.roles[:editor]).map{|x| x.person}
  end

  def translators
    return realizers.includes(:person).where(role: Realizer.roles[:translator]).map {|x| x.person}
  end

  def should_be_copyrighted?
    creators = works[0].persons
    realizer_people = realizers.map{|r| r.person}
    tocheck = creators + realizer_people
    ret = false
    tocheck.each{|p|
      ret = true unless p.public_domain
      break if ret
    }
    return ret
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
    b = determine_is_translation?
    self.translation = determine_is_translation? unless b.nil?
    return true
  end

  def norm_dates
    nd = normalize_date(self.date)
    self.normalized_pub_date = nd unless nd.nil?
  end
end
