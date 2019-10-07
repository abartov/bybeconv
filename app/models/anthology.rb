class Anthology < ApplicationRecord
  belongs_to :user

  enum access: %i(priv unlisted pub)
end
