# frozen_string_literal: true

class AddDefaultsFieldsToIngestible < ActiveRecord::Migration[6.1]
  def change
    add_column :ingestibles, :problem, :string
    add_column :ingestibles, :orig_lang, :string
    add_column :ingestibles, :year_published, :string
    add_column :ingestibles, :genre, :string
    add_column :ingestibles, :publisher, :string
    add_column :ingestibles, :pub_link, :string
    add_column :ingestibles, :pub_link_text, :string
    rename_column :ingestibles, :defaults, :default_authorities
  end
end
