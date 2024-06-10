# frozen_string_literal: true

class AddTimestampsToIngestible < ActiveRecord::Migration[6.1]
  def change
    add_column :ingestibles, :markdown_updated_at, :datetime
    add_column :ingestibles, :works_buffer_updated_at, :datetime
  end
end
