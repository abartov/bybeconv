class Proof < ActiveRecord::Base
  attr_accessible :about, :from, :what, :resolved_by, :status, :subscribe, :highlight, :recommended_by, :manifestation_id

  belongs_to :html_file
  belongs_to :user, foreign_key: 'reported_by'
  belongs_to :user, foreign_key: 'resolved_by'

  belongs_to :manifestation
end
