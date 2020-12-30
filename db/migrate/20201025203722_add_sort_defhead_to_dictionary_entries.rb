class AddSortDefheadToDictionaryEntries < ActiveRecord::Migration[5.2]
  def change
    add_column :dictionary_entries, :sort_defhead, :string
    add_index :dictionary_entries, :sort_defhead
  end
end
