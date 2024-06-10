# frozen_string_literal: true

class AddFieldsToIngestible < ActiveRecord::Migration[6.1]
  def change
    add_column :ingestibles, :attach_photos, :boolean, null: false, default: false
    add_column :ingestibles, :no_volume, :boolean, null: false, default: false
    add_column :ingestibles, :toc_buffer, :text, limit: 50_000
    add_column :ingestibles, :volume_id, :integer
    add_index :ingestibles, :volume_id
    add_column :ingestibles, :works_buffer, :text, limit: 16_000_000
  end
end
