class AddImageUrlToPerson < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :image_url, :string
  end
end
