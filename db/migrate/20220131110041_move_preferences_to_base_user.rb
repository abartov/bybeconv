class MovePreferencesToBaseUser < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :user_preferences, :users
    remove_index :user_preferences, [:user_id, :name]
    rename_table :user_preferences, :base_user_preferences
    add_belongs_to :base_user_preferences, :base_user, foreign_key: true, index: true

    execute 'update base_user_preferences bup set base_user_id = (select id from base_users bu where bu.user_id = bup.user_id)'

    change_column :base_user_preferences, :base_user_id, :bigint, null: false

    remove_column :base_user_preferences, :user_id
  end
end
