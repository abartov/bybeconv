class AddTocIdToPerson < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :toc_id, :integer
  end
end
