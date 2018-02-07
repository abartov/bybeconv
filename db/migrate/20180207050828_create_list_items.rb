class CreateListItems < ActiveRecord::Migration
  def change
    create_table :list_items do |t|
      t.references :user, index: true, foreign_key: true
      t.string :listkey
      t.references :item, polymorphic: true, index: true

      t.timestamps null: false
    end
    add_index :list_items, :listkey
    add_index :list_items, [:listkey, :item_id] # for system lists (e.g. whitelists)
    add_index :list_items, [:listkey, :user_id, :item_id] # for user-related lists
  end
end
