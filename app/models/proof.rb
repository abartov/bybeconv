# frozen_string_literal: true

# Proof is an user-provided report about found mistakes in documents (Manifestation, Authority, etc)
class Proof < ApplicationRecord
  STATUSES = %w(new assigned fixed escalated wontfix spam).freeze

  belongs_to :reporter, foreign_key: 'reported_by', class_name: 'User', optional: true # not used ATM
  belongs_to :resolver, foreign_key: 'resolved_by', class_name: 'User', optional: true

  belongs_to :item, polymorphic: true # item where mistake was found

  validates :status, inclusion: { in: STATUSES }
end
