class DropExpressionsGenre < ActiveRecord::Migration[5.2]
  def change
    remove_column :expressions, :genre
  end
end
