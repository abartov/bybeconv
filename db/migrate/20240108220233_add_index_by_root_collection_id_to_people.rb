class AddIndexByRootCollectionIdToPeople < ActiveRecord::Migration[6.1]
  def change
    add_index :people, :root_collection_id # unique?
  end
end
