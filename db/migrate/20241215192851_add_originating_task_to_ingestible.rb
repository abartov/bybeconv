# frozen_string_literal: true

class AddOriginatingTaskToIngestible < ActiveRecord::Migration[6.1]
  def change
    add_column :ingestibles, :originating_task, :string
    add_index :ingestibles, :originating_task
  end
end
