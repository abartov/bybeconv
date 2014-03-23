class AddStrippedNikkudToHtmlFile < ActiveRecord::Migration
  def change
    add_column :html_files, :stripped_nikkud, :boolean
  end
end
