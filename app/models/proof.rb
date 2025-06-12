class Proof < ApplicationRecord
  STATUSES = %w(new assigned fixed escalated wontfix spam)

  # TODO: add indexes!
  belongs_to :html_file
  belongs_to :reporter, foreign_key: 'reported_by', class_name: 'User'
  belongs_to :resolver, foreign_key: 'resolved_by', class_name: 'User'

  belongs_to :manifestation

  validates_inclusion_of :status, in: STATUSES
end
