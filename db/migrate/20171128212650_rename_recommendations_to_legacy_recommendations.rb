class RenameRecommendationsToLegacyRecommendations < ActiveRecord::Migration
  def change
    rename_table 'recommendations', 'legacy_recommendations'
  end
end
