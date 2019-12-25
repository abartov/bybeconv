class AddIndexByStatus < ActiveRecord::Migration[5.2]
  def change
    add_index :manifestations, :status
  end
end
