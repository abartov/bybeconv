class Holding < ActiveRecord::Base
  belongs_to :publication
  belongs_to :bib_source
  enum status: [:todo, :scanned, :obtained, :missing, :irrelevant]
end
