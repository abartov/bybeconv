class AddIndexByUpdatedAtToManifestation < ActiveRecord::Migration[6.1]
  def change
    add_index :manifestations, :updated_at
  end
end
