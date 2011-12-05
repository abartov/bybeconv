class AddFlagsToHtmlFile < ActiveRecord::Migration
  def change
    add_column :html_files, :tables, :boolean
    add_column :html_files, :footnotes, :boolean
    add_column :html_files, :images, :boolean
  end
end
