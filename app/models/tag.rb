class Tag < ActiveRecord::Base
  attr_accessible :created_by, :name, :status
  has_many :taggings
  has_many :manifestations, through: :taggings, class_name: 'Manifestation'
  belongs_to :creator, foreign_key: :created_by, class_name: 'User'
  enum status: [:pending, :approved]

  scope :pending, -> { where(status: Tag.statuses[:pending]) }
  scope :approved, -> { where(status: Tag.statuses[:approved]) }
end
