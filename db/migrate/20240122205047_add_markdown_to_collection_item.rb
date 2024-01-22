class AddMarkdownToCollectionItem < ActiveRecord::Migration[6.1]
  def change
    add_column :collection_items, :markdown, :string, limit: 2048
  end
end
