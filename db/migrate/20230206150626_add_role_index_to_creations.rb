class AddRoleIndexToCreations < ActiveRecord::Migration[5.2]
  def change
    add_index :creations, [:person_id, :role]
  end
end
