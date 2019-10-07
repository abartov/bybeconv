class CreateAnthologyTexts < ActiveRecord::Migration[5.2]
  def change
    create_table :anthology_texts do |t|
      t.string :title
      t.text :body
      t.references :anthology, foreign_key: true
      t.references :manifestation, foreign_key: true, type: :integer

      t.timestamps
    end
  end
end
