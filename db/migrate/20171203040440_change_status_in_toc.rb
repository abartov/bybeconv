class ChangeStatusInToc < ActiveRecord::Migration[4.2]
  def change
    remove_column :tocs, :status
    add_column :tocs, :status, :integer
  end
end
