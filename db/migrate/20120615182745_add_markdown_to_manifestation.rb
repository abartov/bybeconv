class AddMarkdownToManifestation < ActiveRecord::Migration
  def change
    add_column :manifestations, :markdown, :text
    remove_column :manifestations, :markdown_path
  end
end
