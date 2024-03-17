class CreateUserBlocks < ActiveRecord::Migration[6.1]
  def change
    create_table :user_blocks do |t|
      t.references :user, foreign_key: true, type: :integer
      t.string :context
      t.datetime :expires_at
      t.integer :blocker_id
      t.string :reason

      t.timestamps
    end
    add_index :user_blocks, :context
  end
end
