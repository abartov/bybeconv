class AddWikidataIdToPerson < ActiveRecord::Migration
  def change
    add_column :people, :wikidata_id, :integer
  end
end
