class Holding < ActiveRecord::Base
  belongs_to :publication
  enum status: [:todo, :scanned, :obtained, :missing, :irrelevant]
end
