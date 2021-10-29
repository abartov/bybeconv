class PublicationsLongerTitles < ActiveRecord::Migration[4.2]
  def change
    change_column :publications, :title, :string, :limit => 1024

  end
end
