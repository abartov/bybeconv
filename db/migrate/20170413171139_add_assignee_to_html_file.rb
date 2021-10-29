class AddAssigneeToHtmlFile < ActiveRecord::Migration[4.2]
  def change
    add_column :html_files, :assignee_id, :integer
    add_index :html_files, :assignee_id
  end
end
