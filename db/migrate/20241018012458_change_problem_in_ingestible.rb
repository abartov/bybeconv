# frozen_string_literal: true

class ChangeProblemInIngestible < ActiveRecord::Migration[6.1]
  def change
    change_column :ingestibles, :problem, :text, limit: 2.megabytes
  end
end
