class AddPublicDomainToPerson < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :public_domain, :boolean
  end
end
