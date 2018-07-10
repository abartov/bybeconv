class Publication < ActiveRecord::Base
  belongs_to :person
  belongs_to :bib_source
  has_many :holdings
  enum status: [:todo, :scanned, :obtained, :missing, :irrelevant]
end
