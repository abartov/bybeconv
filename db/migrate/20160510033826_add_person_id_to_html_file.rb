class AddPersonIdToHtmlFile < ActiveRecord::Migration
  def change
    add_column :html_files, :person_id, :integer
  end
end
