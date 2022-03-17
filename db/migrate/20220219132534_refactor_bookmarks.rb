class RefactorBookmarks < ActiveRecord::Migration[5.2]
  def change
    # We should only have one bookmark per user per manifestation, but we have some duplicated entities in db
    # this script will remove duplicated records
    execute <<~sql
      delete b from
        bookmarks b
        join bookmarks b2 on 
          b2.base_user_id = b.base_user_id
          and b2.manifestation_id = b.manifestation_id
          and b2.id > b.id
    sql

    # adding uniqueness constraint to prevent appearance of such duplicates in future
    add_index :bookmarks, [:base_user_id, :manifestation_id], unique: true

    # this column is not used
    remove_column :bookmarks, :context
  end
end
