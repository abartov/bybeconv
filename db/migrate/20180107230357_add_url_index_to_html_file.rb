class AddUrlIndexToHtmlFile < ActiveRecord::Migration
  def change
    add_index :html_files, :url
  end
end
