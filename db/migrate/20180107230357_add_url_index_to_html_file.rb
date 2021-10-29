class AddUrlIndexToHtmlFile < ActiveRecord::Migration[4.2]
  def change
    add_index :html_files, :url
  end
end
