class AddPersonIdToHtmlDir < ActiveRecord::Migration[4.2]
  def change
    add_column :html_dirs, :person_id, :integer
  end
end
