class AddCachedHeadingLinesToManifestation < ActiveRecord::Migration[4.2]
  def change
    add_column :manifestations, :cached_heading_lines, :text
    i = 0
    total = Manifestation.count
    puts "Calculating cached heading line numbers..."
    Manifestation.all.each{ |m|
      puts "done #{i} out of #{total} so far." if i % 200 == 0
      m.recalc_heading_lines!
      m.recalc_cached_people! # discovered a bug in this other recalc, so fixing it en passant.
      i += 1
    }
  end
end
