# frozen_string_literal: true

class IncreaseAltTitleInCollectionItem < ActiveRecord::Migration[6.1]
  def change
    change_column :collection_items, :alt_title, :string, limit: 2048   
  end
end
