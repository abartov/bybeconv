class ExternalLink < ActiveRecord::Base
  attr_accessible :linktype, :status, :url

  belongs_to :manifestation
end
