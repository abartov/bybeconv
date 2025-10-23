# frozen_string_literal: true

class AddCollectionAuthoritiesToIngestibles < ActiveRecord::Migration[8.0]
  def change
    add_column :ingestibles, :collection_authorities, :text
  end
end
