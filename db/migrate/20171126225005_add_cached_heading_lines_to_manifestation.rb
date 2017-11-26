class AddCachedHeadingLinesToManifestation < ActiveRecord::Migration
  def change
    add_column :manifestations, :cached_heading_lines, :string
    i = 0
    total = Manifestation.count
    puts "Calculating cached heading line numbers..."
    Manifestation.all.each{|m|
      puts "done #{i} out of #{total} so far." if i % 200 == 0
      m.recalc_heading_lines!
      i += 1
    }
  end
end
