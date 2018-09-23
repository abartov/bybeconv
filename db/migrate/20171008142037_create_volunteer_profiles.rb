class CreateVolunteerProfiles < ActiveRecord::Migration
  def change
    create_table :volunteer_profiles do |t|
      t.string :name
      t.text :bio
      t.text :about
      t.string   :profile_image_file_name,    limit: 255
      t.string   :profile_image_content_type, limit: 255
      t.integer  :profile_image_file_size,    limit: 4
      t.datetime :profile_image_updated_at

      t.timestamps null: false
    end
  end
end
