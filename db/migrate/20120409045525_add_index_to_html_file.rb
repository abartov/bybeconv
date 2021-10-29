class AddIndexToHtmlFile < ActiveRecord::Migration[4.2]
  def change
    add_index :html_files, :path
  end
end
