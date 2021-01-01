class IncreaseDefTextSize < ActiveRecord::Migration[5.2]
  def change
    change_column :dictionary_entries, :deftext, :text, :limit => 16777210 # near mediumtext limit, more than enough for any def.
  end
end
