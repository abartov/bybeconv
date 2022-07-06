class AddPrimaryFlagToWorks < ActiveRecord::Migration[5.2]
  def change
    add_column :works, :primary, :boolean, null: false, default: true
    change_column_default :works, :primary, from: false, to: nil
  end
end
