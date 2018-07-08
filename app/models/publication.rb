class Publication < ActiveRecord::Base
  belongs_to :person
  belongs_to :bib_source
  enum status: [:todo, :scanned, :obtained, :missing, :irrelevant]
end
