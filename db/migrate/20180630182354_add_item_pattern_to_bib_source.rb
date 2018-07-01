class AddItemPatternToBibSource < ActiveRecord::Migration
  def change
    add_column :bib_sources, :item_pattern, :string, limit: 2048
  end
end
