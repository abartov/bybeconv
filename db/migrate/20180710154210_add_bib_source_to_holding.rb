class AddBibSourceToHolding < ActiveRecord::Migration
  def change
    add_reference :holdings, :bib_source, index: true, foreign_key: true
  end
end
