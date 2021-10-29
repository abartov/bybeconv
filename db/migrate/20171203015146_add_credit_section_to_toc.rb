class AddCreditSectionToToc < ActiveRecord::Migration[4.2]
  def change
    add_column :tocs, :credit_section, :text
  end
end
