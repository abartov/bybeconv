class CreateApiKeys < ActiveRecord::Migration
  def change
    create_table :api_keys do |t|
      t.string :email, limit: 100
      t.string :description
      t.string :key
      t.integer :status

      t.timestamps
    end
    add_index :api_keys, :email, :unique => true
  end
end
