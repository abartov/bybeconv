class CreatePublications < ActiveRecord::Migration[4.2]
  def change
    create_table :publications do |t|
      t.string :title
      t.string :publisher_line
      t.string :author_line
      t.text :notes
      t.string :source_id
      t.references :person, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
