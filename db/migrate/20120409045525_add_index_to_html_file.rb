class AddIndexToHtmlFile < ActiveRecord::Migration
  def change
    add_index :html_files, :path
  end
end
