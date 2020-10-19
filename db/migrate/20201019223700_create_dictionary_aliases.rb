class CreateDictionaryAliases < ActiveRecord::Migration[5.2]
  def change
    create_table :dictionary_aliases do |t|
      t.references :dictionary_entry, foreign_key: true
      t.string :alias

      t.timestamps
    end
  end
end
