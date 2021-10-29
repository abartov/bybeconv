class CreateAboutnesses < ActiveRecord::Migration[4.2]
  def change
    create_table :aboutnesses do |t|
      t.references :work, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.integer :status
      t.integer :wikidata_qid, index: true
      t.references :aboutable, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
