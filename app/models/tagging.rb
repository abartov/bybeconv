 class Tagging < ApplicationRecord

  belongs_to :tag, foreign_key: 'tag_id', counter_cache: true
  belongs_to :taggable, polymorphic: true # taggable things include Manifestations, People, Anthologies, ...

#  belongs_to :manifestation, foreign_key: 'manifestation_id'
  belongs_to :suggester, foreign_key: 'suggested_by', class_name: 'User'
  belongs_to :approver, foreign_key: 'approved_by', class_name: 'User'
  validates :suggester, presence: true
  validates :status, presence: true
  validates :tag, presence: true
  validates :taggable, presence: true
  
  enum status: [:pending, :approved, :rejected, :semiapproved]

  scope :pending, -> { where(status: Tagging.statuses[:pending]) }
  scope :approved, -> { where(status: Tagging.statuses[:approved]) }
  scope :semiapproved, -> { where(status: Tagging.statuses[:semiapproved]) }
  scope :rejected, -> { where(status: Tagging.statuses[:rejected]) }
  scope :by_suggester, ->(user) { where(suggested_by: user.id) }

  update_index(->(tagging) { tagging.taggable.class.to_s == 'Person' ? 'people' : 'manifestations'}) {taggable} # change in tags should be reflected in search indexes

  def approve!(approver)
    self.approved_by = approver.id
    self.status = 'approved'
    self.save
  end
 
  def reject!(approver)
    self.approved_by = approver.id
    self.status = 'rejected'
    self.save
  end
end
