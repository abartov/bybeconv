class AddItemPatternToBibSource < ActiveRecord::Migration[4.2]
  def change
    add_column :bib_sources, :item_pattern, :string, limit: 2048
  end
end
