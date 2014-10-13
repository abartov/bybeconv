class Proof < ActiveRecord::Base
  belongs_to :html_file
  belongs_to :user
end
