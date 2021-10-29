class CreateStaticPages < ActiveRecord::Migration[4.2]
  TEXT_BYTES = 1_073_741

  def change
    create_table :static_pages do |t|
      t.string :tag
      t.string :title
      t.text :body, limit: TEXT_BYTES
      t.integer :status
      t.integer :mode

      t.timestamps null: false
    end
  end
end
