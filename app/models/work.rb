include BybeUtils
class Work < ApplicationRecord
  GENRES = %w(poetry prose drama fables article memoir letters reference lexicon).freeze
  
  has_many :expressions, inverse_of: :work, dependent: :destroy
  has_many :creations, dependent: :destroy
  has_many :persons, through: :creations, class_name: 'Person'
  has_many :aboutnesses, as: :aboutable, dependent: :destroy # works that are ABOUT this work
  has_many :topics, class_name: 'Aboutness' # topics that this work is ABOUT 

  has_many :taggings, as: :taggable, dependent: :destroy
  has_many :tags, through: :taggings, class_name: 'Tag'

  validates_inclusion_of :genre, in: GENRES
  validates_inclusion_of :primary, in: [true, false]

  before_save :norm_dates
  # has_and_belongs_to_many :people # superseded by creations and persons above

  def authors
    return creations.to_a.select(&:author?).map(&:person)
  end

  def illustrators
    return creations.to_a.select(&:illustrator?).map(&:person)
  end

  def first_author
    creations.each do |c|
      return c.person if c.role == 'author'
    end
    return nil
  end

  def works_about
    # TODO: accommodate works about *expressions* (e.g. an article about a *translation* of Homer's Iliad, not the Iliad)
    Work.joins(:topics).where('aboutnesses.aboutable_id': self.id, 'aboutnesses.aboutable_type': 'Work')
  end

  protected
  def norm_dates
    nd = normalize_date(self.date)
    self.normalized_creation_date = nd unless nd.nil?
  end
end
