class AddTitleToHtmlFile < ActiveRecord::Migration[4.2]
  def change
    add_column :html_files, :title, :string
  end
end
