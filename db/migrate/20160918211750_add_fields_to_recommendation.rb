class AddFieldsToRecommendation < ActiveRecord::Migration
  def change
    add_column :recommendations, :recommended_by, :integer
    add_column :recommendations, :manifestation_id, :integer
  end
end
