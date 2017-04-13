class AddAssigneeToHtmlFile < ActiveRecord::Migration
  def change
    add_column :html_files, :assignee_id, :integer
    add_index :html_files, :assignee_id
  end
end
