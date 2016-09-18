class Tagging < ActiveRecord::Base
  attr_accessible :approved_by, :manifestation_id, :status, :suggested_by, :tag_id

  PENDING = 0
  APPROVED = 1

  belongs_to :tags
  belongs_to :manifestations, :foreign_key => 'manifestation_id'

  scope :approved, where(status: APPROVED)
end
