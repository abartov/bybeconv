class Aboutness < ApplicationRecord
  belongs_to :work
  belongs_to :user
  belongs_to :aboutable, polymorphic: true
end
