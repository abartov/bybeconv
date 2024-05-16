# frozen_string_literal: true

class ChangePeopleWikidataIdToWikidataUri < ActiveRecord::Migration[6.1]
  def change
    add_column :people, :wikidata_uri, :string

    execute <<~SQL
      update people
      set wikidata_uri = CONCAT('https://wikidata.org/wiki/q', wikidata_id)
      where wikidata_id is not null
    SQL

    remove_column :people, :wikidata_id
  end
end
