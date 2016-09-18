class Recommendation < ActiveRecord::Base
  attr_accessible :about, :from, :resolved_by, :status, :subscribe, :what, :recommended_by

  belongs_to :html_file # legacy system (will be migrated or eliminated at some point; for now will co-exist quietly)
  belongs_to :manifestation # new system
  belongs_to :recommender, class_name: 'User', foreign_key: :recommended_by
end
