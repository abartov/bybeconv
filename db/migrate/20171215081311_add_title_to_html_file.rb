class AddTitleToHtmlFile < ActiveRecord::Migration
  def change
    add_column :html_files, :title, :string
  end
end
