class CreateProofs < ActiveRecord::Migration
  def change
    create_table :proofs do |t|
      t.string :from
      t.string :about
      t.text :what
      t.boolean :subscribe
      t.string :status
      t.string :assignee

      t.timestamps
    end
  end
end
