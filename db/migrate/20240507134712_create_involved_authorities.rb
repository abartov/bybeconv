# frozen_string_literal: true

class CreateInvolvedAuthorities < ActiveRecord::Migration[6.1]
  def change
    execute 'drop table if exists involved_authorities'

    create_table :involved_authorities, id: :integer do |t|
      t.belongs_to :person, null: false, foreign_key: true, type: :integer
      t.belongs_to :work, null: true, foreign_key: true, type: :integer
      t.belongs_to :expression, null: true, foreign_key: true, type: :integer
      t.integer :role, null: false
      t.timestamps
    end
  end
end
