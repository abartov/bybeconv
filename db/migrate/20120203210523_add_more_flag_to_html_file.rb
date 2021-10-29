class AddMoreFlagToHtmlFile < ActiveRecord::Migration[4.2]
  def change
    add_column :html_files, :nikkud, :string
    add_column :html_files, :line_numbers, :boolean
    add_column :html_files, :indentation, :string
    add_column :html_files, :headings, :string
  end
end
