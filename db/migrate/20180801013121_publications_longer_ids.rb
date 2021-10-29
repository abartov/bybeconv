class PublicationsLongerIds < ActiveRecord::Migration[4.2]
  def change
    change_column :publications, :source_id, :string, :limit => 1024
    change_column :publications, :author_line, :string, :limit => 1024
    change_column :holdings, :source_id, :string, :limit => 1024

  end
end
