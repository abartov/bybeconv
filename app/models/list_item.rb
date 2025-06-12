class ListItem < ApplicationRecord
  belongs_to :user
  belongs_to :item, polymorphic: true
  # specific scope for the various entities that can be items
  belongs_to :proof, -> { where(list_items: { item_type: 'Proof' }) }, foreign_key: 'item_id'
  belongs_to :manifestation, -> { where(list_items: { item_type: 'Manifestation' }) }, foreign_key: 'item_id'
  belongs_to :publication, -> { where(list_items: { item_type: 'Publication' }) }, foreign_key: 'item_id'

end
