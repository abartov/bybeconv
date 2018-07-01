class AddStatusToBibSource < ActiveRecord::Migration
  def change
    add_column :bib_sources, :status, :integer
  end
end
