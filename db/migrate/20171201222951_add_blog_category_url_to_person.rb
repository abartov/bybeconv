class AddBlogCategoryUrlToPerson < ActiveRecord::Migration
  def change
    add_column :people, :blog_category_url, :string
  end
end
