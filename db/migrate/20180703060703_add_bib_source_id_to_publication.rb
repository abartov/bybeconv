class AddBibSourceIdToPublication < ActiveRecord::Migration
  def change
    add_reference :publications, :bib_source, index: true, foreign_key: true
  end
end
