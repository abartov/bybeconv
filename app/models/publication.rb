class Publication < ActiveRecord::Base
  belongs_to :person
  belongs_to :bib_source
  has_many :holdings, :dependent => :destroy
  enum status: [:todo, :scanned, :obtained, :irrelevant]
end
