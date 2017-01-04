class AddAttachmentProfileImageToPeople < ActiveRecord::Migration
  def self.up
    change_table :people do |t|
      t.attachment :profile_image
    end
  end

  def self.down
    remove_attachment :people, :profile_image
  end
end
