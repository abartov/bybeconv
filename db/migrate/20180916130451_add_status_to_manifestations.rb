class AddStatusToManifestations < ActiveRecord::Migration[4.2]
  def change
    add_column :manifestations, :status, :integer
    print "Setting status to 'published' for all existing manifestations... "
    Manifestation.update_all("status = #{Manifestation.statuses[:published]}") # make all current manifestations 'published', as a one-time thing.
    puts "done."
  end
end
