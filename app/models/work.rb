class Work < ApplicationRecord
  has_and_belongs_to_many :expressions
  has_many :creations
  has_many :persons, through: :creations, class_name: 'Person'
  has_many :aboutnesses, as: :aboutable
  has_many :topics, class_name: 'Aboutness', source: :work

  # has_and_belongs_to_many :people # superseded by creations and persons above

  def authors
    return creations.where(role: Creation.roles[:author]).map {|x| x.person}
  end

  def first_author
    creations.each do |c|
      return c.person if c.role == 'author'
    end
    return nil
  end

  def title_and_authors_string
    # TBD
  end
end
