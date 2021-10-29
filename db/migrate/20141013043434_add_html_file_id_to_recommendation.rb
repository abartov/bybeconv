class AddHtmlFileIdToRecommendation < ActiveRecord::Migration[4.2]
  def change
    add_column :recommendations, :html_file_id, :integer
  end
end
