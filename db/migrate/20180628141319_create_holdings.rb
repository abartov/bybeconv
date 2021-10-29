class CreateHoldings < ActiveRecord::Migration[4.2]
  def change
    create_table :holdings do |t|
      t.references :publication, index: true, foreign_key: true
      t.string :source_id
      t.string :source_name

      t.timestamps null: false
    end
  end
end
