class DropPeopleWorksTable < ActiveRecord::Migration[4.2]
  def change
    drop_table :people_works
  end
end
