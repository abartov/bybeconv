class CreateVolunteerProfileFeatures < ActiveRecord::Migration
  def change
    create_table :volunteer_profile_features do |t|
      t.references :volunteer_profile, index: true, foreign_key: true
      t.datetime :fromdate
      t.datetime :todate

      t.timestamps null: false
    end
  end
end
