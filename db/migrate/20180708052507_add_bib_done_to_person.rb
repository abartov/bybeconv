class AddBibDoneToPerson < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :bib_done, :boolean
  end
end
