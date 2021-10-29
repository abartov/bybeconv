class AddStrippedNikkudToHtmlFile < ActiveRecord::Migration[4.2]
  def change
    add_column :html_files, :stripped_nikkud, :boolean
  end
end
