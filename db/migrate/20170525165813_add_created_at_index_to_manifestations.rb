class AddCreatedAtIndexToManifestations < ActiveRecord::Migration[4.2]
  def change
    add_index :manifestations, :created_at
  end
end
