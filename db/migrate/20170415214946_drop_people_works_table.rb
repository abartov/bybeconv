class DropPeopleWorksTable < ActiveRecord::Migration
  def change
    drop_table :people_works
  end
end
