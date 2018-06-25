class AddWikidataLabelToAboutness < ActiveRecord::Migration
  def change
    add_column :aboutnesses, :wikidata_label, :string
  end
end
