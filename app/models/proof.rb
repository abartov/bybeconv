class Proof < ApplicationRecord
# TODO: add indexes!
  belongs_to :html_file
  belongs_to :user, foreign_key: 'reported_by'
  belongs_to :user, foreign_key: 'resolved_by'

  belongs_to :manifestation
end
