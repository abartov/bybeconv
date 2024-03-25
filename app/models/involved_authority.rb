class InvolvedAuthority < ApplicationRecord
  enum role: { author: 0, editor: 1, illustrator: 2, translator: 3, photographer: 4, designer: 5, contributor: 6, other: 7 }

  belongs_to :authority, polymorphic: true # Person or CorporateBody
  belongs_to :item, polymorphic: true # Work or Expression

  validates :authority, presence: true
  validates :item, presence: true
  validates :role, presence: true

  paginates_per 100

  # type-specific associations

  belongs_to :person, -> { where(involved_authorities: {authority_type: 'Person'}) }, foreign_key: 'authority_id', optional: true
  # Ensure review.shop returns nil unless review.reviewable_type == "Shop"
  def person
    return unless authority_type == 'Person'
    super
  end

  belongs_to :corporate_body, -> { where(involved_authorities: {authority_type: 'CorporateBody'}) }, foreign_key: 'authority_id', optional: true
  def corporate_body
    return unless authority_type == 'CorporateBody'
    super
  end

  belongs_to :work, -> { where(involved_authorities: {item_type: 'Work'}) }, foreign_key: 'item_id', optional: true
  def work
    return unless item_type == 'Work'
    super
  end

  belongs_to :expression, -> { where(involved_authorities: {item_type: 'Expression'}) }, foreign_key: 'item_id', optional: true
  def expression
    return unless item_type == 'Expression'
    super
  end

end
