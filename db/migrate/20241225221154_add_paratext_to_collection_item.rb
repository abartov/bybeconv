# frozen_string_literal: true

class AddParatextToCollectionItem < ActiveRecord::Migration[6.1]
  def change
    add_column :collection_items, :paratext, :boolean
    change_column :collection_items, :markdown, :text
    puts 'Updating paratext flag for existing paratext items'
    CollectionItem.where(item_type: 'paratext').update_all(paratext: true, item_type: nil)
  end
end
