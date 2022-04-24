class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :manifestations, through: :taggings, class_name: 'Manifestation'
  belongs_to :creator, foreign_key: :created_by, class_name: 'User'
  enum status: [:pending, :approved]
end
