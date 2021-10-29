class RemovePersonIdFromToc < ActiveRecord::Migration[4.2]
  def up
    remove_column :tocs, :person_id
  end

  def down
    add_column :tocs, :person_id, :integer
  end
end
