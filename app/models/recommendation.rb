class Recommendation < ActiveRecord::Base
  belongs_to :user
  belongs_to :approver, foreign_key: 'approved_by', class_name: 'User'
  belongs_to :manifestation
end
