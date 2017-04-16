class ExternalLink < ActiveRecord::Base
  attr_accessible :linktype, :status, :description, :url

  belongs_to :manifestation
end
