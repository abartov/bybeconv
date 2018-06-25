class Aboutness < ActiveRecord::Base
  belongs_to :work
  belongs_to :user
  belongs_to :aboutable, polymorphic: true
end
