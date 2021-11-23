class ExternalLink < ApplicationRecord
  belongs_to :manifestation

  enum linktype: {
    wikipedia: 0,
    blog: 1,
    youtube: 2,
    other: 3,
    publisher_site: 4
  }, _prefix: true

  enum status: {
    approved: 0,
    submitted: 1,
    rejected: 2
  }, _prefix: true
end
