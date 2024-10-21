# frozen_string_literal: true

class AddProspectiveVolumeTitleToIngestible < ActiveRecord::Migration[6.1]
  def change
    add_column :ingestibles, :prospective_volume_title, :string
  end
end
