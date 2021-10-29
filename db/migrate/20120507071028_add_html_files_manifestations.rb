class AddHtmlFilesManifestations < ActiveRecord::Migration[4.2]
  def change
   create_table :html_files_manifestations, :id => false do |t|
      t.timestamps
      t.integer :html_file_id
      t.integer :manifestation_id
    end
  end
end
