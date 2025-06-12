class AddIndexByStatusToHtmlFile < ActiveRecord::Migration[5.2]
  def change
    add_index :html_files, :status
  end
end
