class Anthology < ApplicationRecord
  belongs_to :user
  has_many :texts, class_name: 'AnthologyText'
  enum access: %i(priv unlisted pub)
end
