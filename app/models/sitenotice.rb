class Sitenotice < ApplicationRecord
  enum :status, { disabled: 0, enabled: 1 }

  validates_presence_of :body, :fromdate, :todate
end
