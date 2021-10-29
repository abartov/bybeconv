class CreateUserPreferences < ActiveRecord::Migration[4.2]
  def change
    create_table :user_preferences do |t|
      t.string :name, null: false
      t.string :value
      t.references :user, foreign_key: true, null: false
    end
    add_index :user_preferences, [ :user_id, :name ], :unique => true
  end
end
