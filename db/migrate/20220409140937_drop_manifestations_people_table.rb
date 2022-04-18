class DropManifestationsPeopleTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :manifestations_people
  end
end
