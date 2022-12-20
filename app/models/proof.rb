class Proof < ApplicationRecord
# TODO: add indexes!
  belongs_to :html_file
  belongs_to :reporter, foreign_key: 'reported_by', class_name: 'User'
  belongs_to :resolver, foreign_key: 'resolved_by', class_name: 'User'

  belongs_to :manifestation
end
