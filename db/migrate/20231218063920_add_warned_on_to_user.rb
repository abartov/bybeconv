class AddWarnedOnToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :warned_on, :date
  end
end
