class AddWikidataLabelToAboutness < ActiveRecord::Migration[4.2]
  def change
    add_column :aboutnesses, :wikidata_label, :string
  end
end
