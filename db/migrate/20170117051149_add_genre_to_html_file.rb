class AddGenreToHtmlFile < ActiveRecord::Migration[4.2]
  def change
    add_column :html_files, :genre, :string
  end
end
