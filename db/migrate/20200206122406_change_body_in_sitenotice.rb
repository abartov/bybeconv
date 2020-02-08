class ChangeBodyInSitenotice < ActiveRecord::Migration[5.2]
  def change
    change_column :sitenotices, :body, :text
  end
end
