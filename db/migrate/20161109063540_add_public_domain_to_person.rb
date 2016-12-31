class AddPublicDomainToPerson < ActiveRecord::Migration
  def change
    add_column :people, :public_domain, :boolean
  end
end
