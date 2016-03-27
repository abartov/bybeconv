class AddPublicDomainToHtmlDir < ActiveRecord::Migration
  def change
    add_column :html_dirs, :public_domain, :boolean
  end
end
