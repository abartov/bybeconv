class AddPublisherToHtmlFile < ActiveRecord::Migration[4.2]
  def change
    add_column :html_files, :publisher, :string
  end
end
