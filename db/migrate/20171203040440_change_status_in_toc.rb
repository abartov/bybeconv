class ChangeStatusInToc < ActiveRecord::Migration
  def change
    remove_column :tocs, :status
    add_column :tocs, :status, :integer
  end
end
