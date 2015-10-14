class AddHtmlFileIdToRecommendation < ActiveRecord::Migration
  def change
    add_column :recommendations, :html_file_id, :integer
  end
end
