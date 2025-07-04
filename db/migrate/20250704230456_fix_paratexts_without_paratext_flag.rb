# frozen_string_literal: true

class FixParatextsWithoutParatextFlag < ActiveRecord::Migration[7.0]
  def change
    print "Fixing paratexts without paratext flag... "
    cis = CollectionItem.where(paratext: nil).where.not(markdown: nil)
    cis.each do |ci|
      ci.update!(paratext: true)
    end
    puts "Done. Fixed #{cis.count} items."
  end
end
