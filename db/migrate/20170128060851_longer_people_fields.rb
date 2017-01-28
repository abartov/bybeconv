class LongerPeopleFields < ActiveRecord::Migration
  def change
    change_column :people, :other_designation, :string, :limit => 1024
    change_column :people, :wikipedia_url, :string, :limit => 1024
    change_column :people, :image_url, :string, :limit => 1024
  end
end
