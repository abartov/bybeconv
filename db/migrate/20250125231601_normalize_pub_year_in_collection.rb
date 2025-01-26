# frozen_string_literal: true

class NormalizePubYearInCollection < ActiveRecord::Migration[6.1]
  def change
    print "Normalizing publication dates in #{Collection.count} collections..."
    updated = 0
    Collection.all.each do |collection|
      if collection.pub_year.present?
        py = collection.pub_year
        collection.pub_year = nil # force a re-normalization
        collection.save!
        collection.pub_year = py
        collection.save!
        updated += 1
      end
    end
    puts "Done. Updated #{updated} collections."
  end
end
