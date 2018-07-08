class AddBibDoneToPerson < ActiveRecord::Migration
  def change
    add_column :people, :bib_done, :boolean
  end
end
