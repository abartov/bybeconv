class Tag < ActiveRecord::Base
  attr_accessible :created_by, :name, :status
  has_many :taggings
  has_many :manifestations, through: :taggings, :class_name => 'Manifestation'
end
