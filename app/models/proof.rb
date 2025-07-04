class Proof < ApplicationRecord
  STATUSES = %w(new assigned fixed escalated wontfix spam)

  # TODO: add indexes!
  belongs_to :html_file, optional: true
  belongs_to :reporter, foreign_key: 'reported_by', class_name: 'User', optional: true
  belongs_to :resolver, foreign_key: 'resolved_by', class_name: 'User', optional: true

  belongs_to :manifestation, optional: true

  validates_inclusion_of :status, in: STATUSES
end
