class TagName < ApplicationRecord
  belongs_to :tag, inverse_of: :tag_names
  scope :approved, -> { joins(:tag).includes(:tag).where(tags: {status: Tag.statuses[:approved]}) }
end
