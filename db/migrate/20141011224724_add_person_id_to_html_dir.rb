class AddPersonIdToHtmlDir < ActiveRecord::Migration
  def change
    add_column :html_dirs, :person_id, :integer
  end
end
