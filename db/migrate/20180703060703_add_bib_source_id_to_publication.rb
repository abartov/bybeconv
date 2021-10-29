class AddBibSourceIdToPublication < ActiveRecord::Migration[4.2]
  def change
    add_reference :publications, :bib_source, index: true, foreign_key: true
  end
end
