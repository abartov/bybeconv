class RenameRecommendationsToLegacyRecommendations < ActiveRecord::Migration[4.2]
  def change
    rename_table 'recommendations', 'legacy_recommendations'
  end
end
