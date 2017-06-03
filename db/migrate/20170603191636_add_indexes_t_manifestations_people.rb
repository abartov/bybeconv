class AddIndexesTManifestationsPeople < ActiveRecord::Migration
  def change
    add_index :manifestations_people, :person_id
    add_index :manifestations_people, :manifestation_id
  end
end
