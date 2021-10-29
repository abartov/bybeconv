class CreateManifestations < ActiveRecord::Migration[4.2]
  def change
    create_table :manifestations do |t|
      t.string :title
      t.string :responsibility_statement
      t.string :edition
      t.string :identifier
      t.string :medium
      t.string :publisher
      t.string :publication_place
      t.string :publication_date
      t.string :series_statement
      t.text :comment

      t.timestamps
    end
  end
end
