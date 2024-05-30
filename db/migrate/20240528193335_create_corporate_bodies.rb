# frozen_string_literal: true

class CreateCorporateBodies < ActiveRecord::Migration[6.1]
  def change
    drop_table :corporate_bodies, if_exists: true

    create_table :corporate_bodies, id: :integer do |t|
      t.string :inception
      t.integer :inception_year
      t.string :dissolution
      t.integer :dissolution_year
      t.string :location
    end

    add_belongs_to :authorities, :corporate_body, type: :integer, index: { unique: true }, null: true, foreign_key: true
  end
end
