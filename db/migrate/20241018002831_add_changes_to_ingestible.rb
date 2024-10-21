class AddChangesToIngestible < ActiveRecord::Migration[6.1]
  def change
    add_column :ingestibles, :changes, :text
    change_column :ingestibles, :markdown, :text, limit: 25.megabytes
    change_column :ingestibles, :works_buffer, :text, limit: 25.megabytes
  end
end
