# frozen_string_literal: true

class ChangeCopyrighted < ActiveRecord::Migration[6.1]
  def change
    add_column :expressions, :intellectual_property, :integer

    execute <<~sql
      update expressions set intellectual_property = case copyrighted when true then 1 when false then 0 else 100 end 
    sql

    change_column_null :expressions, :intellectual_property, false

    remove_column :expressions, :copyrighted

    add_index :expressions, :intellectual_property
  end
end
