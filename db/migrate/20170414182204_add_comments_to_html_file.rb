class AddCommentsToHtmlFile < ActiveRecord::Migration
  def change
    add_column :html_files, :comments, :text
  end
end
