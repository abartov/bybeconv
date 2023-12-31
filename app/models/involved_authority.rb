class InvolvedAuthority < ApplicationRecord
  belongs_to :authority, polymorphic: true
  belongs_to :item, polymorphic: true
end
