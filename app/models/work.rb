include BybeUtils
class Work < ApplicationRecord
  has_and_belongs_to_many :expressions
  has_many :creations
  has_many :persons, through: :creations, class_name: 'Person'
  has_many :aboutnesses, as: :aboutable
  has_many :topics, through: :aboutnesses, source: :work

  before_save :norm_dates
  # has_and_belongs_to_many :people # superseded by creations and persons above

  def authors
    return creations.where(role: Creation.roles[:author]).map {|x| x.person}
  end
  def illustrators
    return creations.where(role: Creation.roles[:illustrator]).map {|x| x.person}
  end

  def first_author
    creations.each do |c|
      return c.person if c.role == 'author'
    end
    return nil
  end

  protected
  def norm_dates
    nd = normalize_date(self.date)
    self.normalized_creation_date = nd unless nd.nil?
  end
end
