class Downloadable < ApplicationRecord
  enum doctype: %i(pdf html docx epub mobi txt odt)
  belongs_to :object, polymorphic: true
  has_one_attached :stored_file # ActiveStorage
end
