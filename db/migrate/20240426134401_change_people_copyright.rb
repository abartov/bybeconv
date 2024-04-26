# frozen_string_literal: true

class ChangePeopleCopyright < ActiveRecord::Migration[6.1]
  def change
    add_column :people, :intellectual_property, :integer

    # setting all non-public-domain authors to 'permission_for_selected'
    execute <<~sql
      update people set intellectual_property = case public_domain when 0 then 5 when 1 then 0 else 100 end 
    sql

    change_column_null :people, :intellectual_property, false
    remove_column :people, :public_domain

    add_index :people, :intellectual_property
  end
end
