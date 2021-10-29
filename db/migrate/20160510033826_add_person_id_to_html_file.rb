class AddPersonIdToHtmlFile < ActiveRecord::Migration[4.2]
  def change
    add_column :html_files, :person_id, :integer
  end
end
