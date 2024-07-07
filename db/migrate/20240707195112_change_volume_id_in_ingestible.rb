class ChangeVolumeIdInIngestible < ActiveRecord::Migration[6.1]
  def up
    add_column :ingestibles, :prospective_volume_id, :string
  end
  def down
    remove_column :ingestibles, :prospective_volume_id
  end
end
