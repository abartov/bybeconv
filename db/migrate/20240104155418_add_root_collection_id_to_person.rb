class AddRootCollectionIdToPerson < ActiveRecord::Migration[6.1]
  def change
    add_column :people, :root_collection_id, :integer
  end
end
