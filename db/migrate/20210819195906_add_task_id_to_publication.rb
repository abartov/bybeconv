class AddTaskIdToPublication < ActiveRecord::Migration[5.2]
  def change
    add_column :publications, :task_id, :integer
    add_index :publications, :task_id
  end
end
