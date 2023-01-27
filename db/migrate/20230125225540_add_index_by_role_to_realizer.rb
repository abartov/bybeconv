class AddIndexByRoleToRealizer < ActiveRecord::Migration[5.2]
  def change
    add_index :realizers, [:role, :person_id]
  end
end
