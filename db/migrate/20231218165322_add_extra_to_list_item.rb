class AddExtraToListItem < ActiveRecord::Migration[6.1]
  def change
    add_column :list_items, :extra, :string
  end
end
