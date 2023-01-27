class CreateBaseUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :base_users do |t|
      t.belongs_to :user, foreign_key: true, index: { unique: true }, type: :integer
      t.string :session_id, index: { unique: true }
    end

    execute 'insert into base_users (user_id) select id from users'
  end
end
