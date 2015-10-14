class CreateRecommendations < ActiveRecord::Migration
  def change
    create_table :recommendations do |t|
      t.string :from
      t.string :about
      t.string :what
      t.boolean :subscribe
      t.string :status
      t.integer :resolved_by

      t.timestamps
    end
  end
end
