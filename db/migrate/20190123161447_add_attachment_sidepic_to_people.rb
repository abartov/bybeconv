class AddAttachmentSidepicToPeople < ActiveRecord::Migration[5.2]
  def self.up
    change_table :people do |t|
      t.attachment :sidepic
    end
  end

  def self.down
    remove_attachment :people, :sidepic
  end
end
