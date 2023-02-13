class AddIndexToListItems < ActiveRecord::Migration[5.2]
  def change
    add_index :list_items, [:listkey, :updated_at]
  end
end
