class AddIndexToImpressions < ActiveRecord::Migration[5.2]
  def change
    add_index :impressions, :updated_at
  end
end
