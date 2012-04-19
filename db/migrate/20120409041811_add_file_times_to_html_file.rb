class AddFileTimesToHtmlFile < ActiveRecord::Migration
  def change
    add_column :html_files, :orig_mtime, :string
    add_column :html_files, :orig_ctime, :string
  end
end
