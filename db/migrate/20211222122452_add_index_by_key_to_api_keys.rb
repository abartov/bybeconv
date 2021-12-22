class AddIndexByKeyToApiKeys < ActiveRecord::Migration[5.2]
  def change
    add_index :api_keys, :key, unique: true
  end
end
