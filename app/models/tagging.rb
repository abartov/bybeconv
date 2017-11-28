class Tagging < ActiveRecord::Base
  attr_accessible :approved_by, :manifestation_id, :status, :suggested_by, :tag_id

  belongs_to :tag, foreign_key: 'tag_id'
  belongs_to :manifestation, foreign_key: 'manifestation_id'
  belongs_to :suggester, foreign_key: 'suggested_by', class_name: 'User'
  belongs_to :approver, foreign_key: 'approved_by', class_name: 'User'
  enum status: [:pending, :approved]

  scope :pending, -> { where(status: Tagging.statuses[:pending]) }
  scope :approved, -> { where(status: Tagging.statuses[:approved]) }

end
