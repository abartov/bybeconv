class AddMoreMetadataToHtmlFile < ActiveRecord::Migration[4.2]
  def change
    add_column :html_files, :orig_author, :string
    add_column :html_files, :orig_author_url, :string
  end
end
