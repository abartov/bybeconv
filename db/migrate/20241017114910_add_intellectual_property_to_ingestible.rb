# frozen_string_literal: true

class AddIntellectualPropertyToIngestible < ActiveRecord::Migration[6.1]
  def change
    add_column :ingestibles, :intellectual_property, :string
  end
end
