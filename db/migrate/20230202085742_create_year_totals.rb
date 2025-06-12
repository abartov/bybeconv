class CreateYearTotals < ActiveRecord::Migration[5.2]
  def change
    create_table :year_totals do |t|
      t.integer :total
      t.integer :year
      t.references :item, polymorphic: true

      t.timestamps
    end
    add_index :year_totals, [ :item_type, :item_id, :year ], name: "index_year_total_by_year", unique: true

  end
end
