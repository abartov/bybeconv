class AddPublicDomainToHtmlDir < ActiveRecord::Migration[4.2]
  def change
    add_column :html_dirs, :public_domain, :boolean
  end
end
