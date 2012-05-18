class AddMarkdownPathToManifestation < ActiveRecord::Migration
  def change
    add_column :manifestations, :markdown_path, :string
  end
end
