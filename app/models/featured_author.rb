class FeaturedAuthor < ActiveRecord::Base
  belongs_to :user
  belongs_to :person

  attr_accessible :title, :body
  has_many :featurings, class_name: 'FeaturedAuthorFeature'

end
