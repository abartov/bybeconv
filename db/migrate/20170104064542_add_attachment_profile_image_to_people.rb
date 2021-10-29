class AddAttachmentProfileImageToPeople < ActiveRecord::Migration[4.2]
  def self.up
    change_table :people do |t|
      t.attachment :profile_image
    end
  end

  def self.down
    remove_attachment :people, :profile_image
  end
end
