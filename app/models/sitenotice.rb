class Sitenotice < ApplicationRecord
  enum status: %i(disabled enabled)

  validates_presence_of :body, :fromdate, :todate
end
