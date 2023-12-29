class CollectionItem < ApplicationRecord
  belongs_to :collection
  belongs_to :item, polymorphic: true
end
