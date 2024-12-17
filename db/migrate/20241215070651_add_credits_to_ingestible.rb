# frozen_string_literal: true

class AddCreditsToIngestible < ActiveRecord::Migration[6.1]
  def change
    add_column :ingestibles, :credits, :text
  end
end
