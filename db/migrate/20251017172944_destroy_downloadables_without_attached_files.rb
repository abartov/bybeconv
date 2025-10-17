# frozen_string_literal: true

class DestroyDownloadablesWithoutAttachedFiles < ActiveRecord::Migration[8.0]
  def up
    print "Removing Downloadables without attached files... "
    count = 0
    Downloadable.find_each do |dl|
      unless dl.stored_file.attached?
        dl.destroy
        count += 1
      end
    end
    puts "#{count} removed."
  end

  def down
    # This migration is irreversible as we're cleaning up broken data
    raise ActiveRecord::IrreversibleMigration
  end
end
