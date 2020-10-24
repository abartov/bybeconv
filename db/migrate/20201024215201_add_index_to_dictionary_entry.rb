class AddIndexToDictionaryEntry < ActiveRecord::Migration[5.2]
  def change
    add_index :dictionary_entries, [:manifestation_id, :sequential_number], name: 'manif_and_seqno_index'
  end
end
