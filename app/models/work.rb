class Work < ActiveRecord::Base
  has_and_belongs_to_many :expressions
  has_many :creations
  has_many :persons, through: :creations, class_name: 'Person'
  has_and_belongs_to_many :people
end
