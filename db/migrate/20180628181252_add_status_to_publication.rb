class AddStatusToPublication < ActiveRecord::Migration
  def change
    add_column :publications, :status, :integer
  end
end
