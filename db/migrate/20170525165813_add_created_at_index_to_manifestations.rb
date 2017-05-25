class AddCreatedAtIndexToManifestations < ActiveRecord::Migration
  def change
    add_index :manifestations, :created_at
  end
end
