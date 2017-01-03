class AddImageUrlToPerson < ActiveRecord::Migration
  def change
    add_column :people, :image_url, :string
  end
end
