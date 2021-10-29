class AddGenreToWork < ActiveRecord::Migration[4.2]
  def change
    add_column :works, :genre, :string
  end
end
