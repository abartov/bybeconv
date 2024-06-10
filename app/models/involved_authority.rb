# frozen_string_literal: true

# This record represent relation between authorities and texts. Text can be represented either as Work or Expression
# instance, but not both.
class InvolvedAuthority < ApplicationRecord
  belongs_to :authority, inverse_of: :involved_authorities
  belongs_to :expression, optional: true
  belongs_to :work, optional: true
  belongs_to :collection, optional: true
  enum role: {
    author: 0,
    editor: 1,
    illustrator: 2,
    translator: 3,
    photographer: 4,
    designer: 5,
    contributor: 6,
    other: 7
  }, _prefix: true

  WORK_ROLES = (roles.keys - %w(translator)).freeze
  EXPRESSION_ROLES = (roles.keys - %w(author)).freeze

  validates :role, presence: true
  validate :validate_item
  validates :role, inclusion: WORK_ROLES, if: ->(ia) { ia.work.present? }
  validates :role, inclusion: EXPRESSION_ROLES, if: ->(ia) { ia.expression.present? }

  private

  def validate_item
    items_count = work.present? ? 1 : 0
    items_count += 1 if expression.present?
    items_count += 1 if collection.present?

    errors.add(:base, :no_item) if items_count.zero?
    errors.add(:base, :multiple_items) if items_count > 1
  end
end
