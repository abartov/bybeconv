class AddAnotherIndexToImpressions < ActiveRecord::Migration[5.2]
  def change
    add_index :impressions, [:impressionable_type, :impressionable_id, :updated_at], name: 'for_compaction'
  end
end
