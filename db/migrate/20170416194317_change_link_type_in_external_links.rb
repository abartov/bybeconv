class ChangeLinkTypeInExternalLinks < ActiveRecord::Migration[4.2]
  def change
    change_column :external_links, :linktype, :integer
  end
end
