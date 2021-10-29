class AddMarkdownPathToManifestation < ActiveRecord::Migration[4.2]
  def change
    add_column :manifestations, :markdown_path, :string
  end
end
