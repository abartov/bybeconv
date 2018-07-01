class Publication < ActiveRecord::Base
  belongs_to :person
  enum status: [:todo, :scanned, :obtained, :missing, :irrelevant]
end
