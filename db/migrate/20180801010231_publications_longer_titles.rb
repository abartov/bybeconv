class PublicationsLongerTitles < ActiveRecord::Migration
  def change
    change_column :publications, :title, :string, :limit => 1024

  end
end
