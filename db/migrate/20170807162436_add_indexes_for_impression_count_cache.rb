class AddIndexesForImpressionCountCache < ActiveRecord::Migration
  def change
    add_index :people, :impressions_count
    add_index :manifestations, :impressions_count
  end
end
