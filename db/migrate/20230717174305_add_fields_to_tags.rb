class AddFieldsToTags < ActiveRecord::Migration[6.1]
  def change
    add_reference :tags, :approver, type: :integer, foreign_key: { to_table: :users } 
  end
end
