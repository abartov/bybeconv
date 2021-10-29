class AddMarkdownToManifestation < ActiveRecord::Migration[4.2]
  def change
    add_column :manifestations, :markdown, :text
    remove_column :manifestations, :markdown_path
  end
end
