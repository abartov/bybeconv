class AddExcludeFromIndexToManifestations < ActiveRecord::Migration[6.1]
  def change
    add_column :manifestations, :exclude_from_index, :boolean, default: false, null: false
  end
end
