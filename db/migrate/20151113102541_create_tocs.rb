class CreateTocs < ActiveRecord::Migration[4.2]
  def change
    create_table :tocs do |t|
      t.integer :person_id
      t.text :toc
      t.string :status

      t.timestamps
    end
    add_index :tocs, :person_id
  end
end
