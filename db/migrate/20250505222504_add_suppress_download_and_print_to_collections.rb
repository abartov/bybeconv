class AddSuppressDownloadAndPrintToCollections < ActiveRecord::Migration[6.1]
  def change
    add_column :collections, :suppress_download_and_print, :boolean, default: false, null: false
  end
end
