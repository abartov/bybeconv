class AddStatusToBibSource < ActiveRecord::Migration[4.2]
  def change
    add_column :bib_sources, :status, :integer
  end
end
