class AddRootCollectionIdToAuthorities < ActiveRecord::Migration[6.1]
  def change
    add_column :authorities, :root_collection_id, :integer
    add_index :authorities, :root_collection_id # unique?
    add_foreign_key :authorities, :collections, column: :root_collection_id
  end
end
