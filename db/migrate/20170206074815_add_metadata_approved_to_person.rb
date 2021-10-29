class AddMetadataApprovedToPerson < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :metadata_approved, :boolean, default: false
  end
end
