class AddGenreToHtmlFile < ActiveRecord::Migration
  def change
    add_column :html_files, :genre, :string
  end
end
