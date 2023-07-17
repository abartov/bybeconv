class AddIndicesToTags < ActiveRecord::Migration[6.1]
  def change
    add_index :tags, :name, unique: true
    add_index :tags, [:status, :name], unique: true
  end
end
