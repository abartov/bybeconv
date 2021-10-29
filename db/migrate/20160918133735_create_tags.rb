class CreateTags < ActiveRecord::Migration[4.2]
  def change
    create_table :tags do |t|
      t.string :name
      t.integer :status
      t.integer :created_by

      t.timestamps
    end
  end
end
