# frozen_string_literal: true

class RenameChangeinIngestible < ActiveRecord::Migration[6.1]
  def change
    rename_column :ingestibles, :changes, :ingested_changes
  end
end
