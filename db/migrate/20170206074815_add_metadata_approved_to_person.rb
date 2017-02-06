class AddMetadataApprovedToPerson < ActiveRecord::Migration
  def change
    add_column :people, :metadata_approved, :boolean, default: false
  end
end
