class AddParasCondensedToHtmlFile < ActiveRecord::Migration
  def change
    add_column :html_files, :paras_condensed, :boolean, default: false
  end
end
