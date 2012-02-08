class AddMoreFlagToHtmlFile < ActiveRecord::Migration
  def change
    add_column :html_files, :nikkud, :string
    add_column :html_files, :line_numbers, :boolean
    add_column :html_files, :indentation, :string
    add_column :html_files, :headings, :string
  end
end
