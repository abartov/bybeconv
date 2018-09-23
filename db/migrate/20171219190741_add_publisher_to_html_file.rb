class AddPublisherToHtmlFile < ActiveRecord::Migration
  def change
    add_column :html_files, :publisher, :string
  end
end
