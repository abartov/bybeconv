# frozen_string_literal: true

class FeaturedContent < ApplicationRecord
  belongs_to :manifestation, optional: true
  belongs_to :authority, inverse_of: :featured_contents, optional: true
  belongs_to :user
  validates :title, :body, presence: true

  # attr_accessible :title, :body, :external_link
  has_many :featured_content_features, class_name: 'FeaturedContentFeature', dependent: :destroy
end
