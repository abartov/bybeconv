class CreateDictionaryLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :dictionary_links do |t|
      t.references :from_entry, foreign_key: {to_table: 'dictionary_entries'}
      t.references :to_entry, foreign_key: {to_table: 'dictionary_entries'}
      t.integer :linktype

      t.timestamps
    end
  end
end
