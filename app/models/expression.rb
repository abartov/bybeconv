class Expression < ActiveRecord::Base
  has_and_belongs_to_many :works
  has_and_belongs_to_many :manifestations
  has_and_belongs_to_many :people
end
