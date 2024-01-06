class CollectionItem < ApplicationRecord
  belongs_to :collection
  belongs_to :item, polymorphic: true

  validates_presence_of :collection, :seqno
end
