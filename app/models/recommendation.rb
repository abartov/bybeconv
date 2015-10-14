class Recommendation < ActiveRecord::Base
  attr_accessible :about, :from, :resolved_by, :status, :subscribe, :what

  belongs_to :html_file
  belongs_to :user
end
