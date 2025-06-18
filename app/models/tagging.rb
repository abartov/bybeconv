# frozen_string_literal: true

# Maps tags to other system object (Authorities, Manifestations, etc)
class Tagging < ApplicationRecord
  belongs_to :tag, counter_cache: true
  belongs_to :taggable, polymorphic: true # taggable things include Manifestations, People, Anthologies, ...

  belongs_to :suggester, foreign_key: 'suggested_by', class_name: 'User'
  belongs_to :approver, foreign_key: 'approved_by', class_name: 'User', optional: true

  validates :status, presence: true
  validates :taggable_type, inclusion: { in: %w(Anthology Authority Collection Expression Manifestation Work) }

  enum status: [:pending, :approved, :rejected, :semiapproved, :escalated]

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

  def escalate!(escalator)
    self.update(approved_by: escalator.id, status: 'escalated')
  end
end
