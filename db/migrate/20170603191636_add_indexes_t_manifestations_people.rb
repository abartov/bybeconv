class AddIndexesTManifestationsPeople < ActiveRecord::Migration[4.2]
  def change
    add_index :manifestations_people, :person_id
    add_index :manifestations_people, :manifestation_id
  end
end
