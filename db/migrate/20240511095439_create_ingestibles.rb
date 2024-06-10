class CreateIngestibles < ActiveRecord::Migration[6.1]
  def change
    execute 'drop table if exists ingestibles'
    create_table :ingestibles do |t|
      t.string :title
      t.integer :status
      t.integer :scenario
      t.text :defaults
      t.text :metadata
      t.text :comments
      t.text :markdown
      t.integer :user_id

      t.timestamps
    end
    add_index :ingestibles, :title
    add_index :ingestibles, :status
    add_index :ingestibles, :user_id
  end
end
