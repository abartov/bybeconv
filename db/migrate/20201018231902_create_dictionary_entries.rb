class CreateDictionaryEntries < ActiveRecord::Migration[5.1]
  def change
    create_table :dictionary_entries do |t|
      t.references :manifestation, foreign_key: true, type: :integer
      t.integer :sequential_number
      t.string :defhead
      t.text :deftext
      t.integer :source_def_id # ID from foreign database where this entry came from, to facilitate gradual imports avoiding duplicates
      t.timestamps
    end
    add_index :dictionary_entries, :sequential_number
    add_index :dictionary_entries, :defhead
    add_index :dictionary_entries, :source_def_id
  end
end
