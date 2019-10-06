class CreateReadingLists < ActiveRecord::Migration[5.2]
  def change
    create_table :reading_lists do |t|
      t.string :title
      t.references :user, foreign_key: true, type: :integer
      t.integer :access

      t.timestamps
    end
  end
end
