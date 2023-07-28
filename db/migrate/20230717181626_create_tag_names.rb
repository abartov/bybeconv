class CreateTagNames < ActiveRecord::Migration[6.1]
  def change
    create_table :tag_names do |t|
      t.references :tag, type: :integer, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
