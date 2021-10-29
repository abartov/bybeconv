class CreateRecommendations < ActiveRecord::Migration[4.2]
  def change
    create_table :recommendations do |t|
      t.text :body
      t.references :user, index: true, foreign_key: true
      t.integer :approved_by
      t.integer :status
      t.references :manifestation, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :recommendations, [ :manifestation_id, :status ]
  end
end
