class AddIndexesToHtmlFilesManifestations < ActiveRecord::Migration
  def change
    add_index :html_files_manifestations, :html_file_id
    add_index :html_files_manifestations, :manifestation_id
  end
end
