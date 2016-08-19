class Manifestation < ActiveRecord::Base
  has_and_belongs_to_many :expressions
  has_and_belongs_to_many :people
  has_paper_trail
end
