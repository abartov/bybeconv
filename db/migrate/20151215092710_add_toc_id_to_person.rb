class AddTocIdToPerson < ActiveRecord::Migration
  def change
    add_column :people, :toc_id, :integer
  end
end
