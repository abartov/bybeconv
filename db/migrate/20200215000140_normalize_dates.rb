require 'bybe_utils'
include BybeUtils
class NormalizeDates < ActiveRecord::Migration[5.2]
  def change
    puts "Normalizing dates in Works... "
    Work.where('date is not null and date <> ""').each do |w|
      nd = normalize_date(w.date)
      unless nd.nil?
        w.normalized_creation_date = nd
        w.save!
      end
    end
    puts "Normalizing dates in Expressions..."
    Expression.where('date is not null and date <> ""').each do |e|
      nd = normalize_date(e.date)
      unless nd.nil?
        e.normalized_pub_date = nd
        e.save!
      end
    end
    puts "Done!"
  end
end
