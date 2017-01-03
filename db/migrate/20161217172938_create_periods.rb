class CreatePeriods < ActiveRecord::Migration
  def change
    create_table :periods do |t|
      t.string :name
      t.text :comments
      t.string :wikipedia_url

      t.timestamps null: false
    end
  end
end
