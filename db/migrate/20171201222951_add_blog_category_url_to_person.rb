class AddBlogCategoryUrlToPerson < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :blog_category_url, :string
  end
end
