class AddMoreMetadataToHtmlFile < ActiveRecord::Migration
  def change
    add_column :html_files, :orig_author, :string
    add_column :html_files, :orig_author_url, :string
  end
end
