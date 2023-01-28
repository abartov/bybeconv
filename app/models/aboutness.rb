class Aboutness < ApplicationRecord
  belongs_to :work # work that is ABOUT something
  belongs_to :user
  belongs_to :aboutable, polymorphic: true # something that the work is ABOUT
end
