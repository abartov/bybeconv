class UserBlock < ApplicationRecord
  belongs_to :user
  belongs_to :blocker, class_name: 'User'
end
