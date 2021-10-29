class RemoveAssigneeFromProofs < ActiveRecord::Migration[4.2]
  def up
    remove_column :proofs, :assignee
  end

  def down
    add_column :proofs, :assignee, :string
  end
end
