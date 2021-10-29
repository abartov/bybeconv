class AddCommentsToHtmlFile < ActiveRecord::Migration[4.2]
  def change
    add_column :html_files, :comments, :text
  end
end
