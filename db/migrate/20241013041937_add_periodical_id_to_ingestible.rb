# frozen_string_literal: true

class AddPeriodicalIdToIngestible < ActiveRecord::Migration[6.1]
  def change
    add_column :ingestibles, :periodical_id, :integer
  end
end
