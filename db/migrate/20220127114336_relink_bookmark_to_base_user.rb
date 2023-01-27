class RelinkBookmarkToBaseUser < ActiveRecord::Migration[5.2]
  def change
    add_belongs_to :bookmarks, :base_user, foreign_key: true, index: true
    execute 'update bookmarks b set base_user_id = (select bu.id from base_users bu where bu.user_id = b.user_id)'
    change_column :bookmarks, :base_user_id, :bigint, null: false
    remove_column :bookmarks, :user_id
  end
end
