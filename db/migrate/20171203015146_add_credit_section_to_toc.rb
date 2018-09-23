class AddCreditSectionToToc < ActiveRecord::Migration
  def change
    add_column :tocs, :credit_section, :text
  end
end
