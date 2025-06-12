class AddAlternateTitlesToManifestation < ActiveRecord::Migration[5.2]
  def change
    add_column :manifestations, :alternate_titles, :string, limit: 512
    print "Populating alternate titles from sort titles...\nProcessing manifestation number "
    i = 0
    j = 0
    Manifestation.all.each do |m|
      if m.sort_title.present? && m.sort_title != m.title
        j += 1
        m.alternate_titles = m.sort_title # sort_titles are often a version of title stripped of diacritics, thus useful for searching
        m.save!
      end
      i += 1
      print "#{i}... " if i % 500 == 0
    end
    print "done. Populated alternate titles in #{j} manifestations.\n"
  end
end
