class AddWikidataQidToTag < ActiveRecord::Migration[6.1]
  def change
    add_column :tags, :wikidata_qid, :string
    add_index :tags, :wikidata_qid
  end
end
