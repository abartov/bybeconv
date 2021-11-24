class AddExternalLinkFk < ActiveRecord::Migration[5.2]
  def change
    print "Ensuring DB integrity re ExternalLinks... "
    bad_links = []
    mids = Manifestation.pluck(:id)
    ExternalLink.where.not(manifestation_id: nil).each do |e|
      bad_links << e unless mids.include?(e.manifestation_id) # find dangling external links
    end
    print "\nFound #{bad_links.count} dangling ExternalLinks. Deleting... "
    bad_links.each{|e| e.destroy}
    puts "done!"
    add_foreign_key "external_links", "manifestations", name: "external_links_manifestation_id_fk"
  end
end
