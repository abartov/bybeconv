class AddAttachmentDocToHtmlFiles < ActiveRecord::Migration[4.2]
  def self.up
    change_table :html_files do |t|
      t.attachment :doc
    end
  end

  def self.down
    remove_attachment :html_files, :doc
  end
end
