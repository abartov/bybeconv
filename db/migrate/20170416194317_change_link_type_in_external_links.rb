class ChangeLinkTypeInExternalLinks < ActiveRecord::Migration
  def change
    change_column :external_links, :linktype, :integer
  end
end
