class Work < ActiveRecord::Base
  has_and_belongs_to_many :expressions
  has_and_belongs_to_many :people
end
