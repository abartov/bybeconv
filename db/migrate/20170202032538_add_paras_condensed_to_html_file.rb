class AddParasCondensedToHtmlFile < ActiveRecord::Migration[4.2]
  def change
    add_column :html_files, :paras_condensed, :boolean, default: false
  end
end
