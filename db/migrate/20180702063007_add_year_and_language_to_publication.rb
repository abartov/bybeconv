class AddYearAndLanguageToPublication < ActiveRecord::Migration[4.2]
  def change
    add_column :publications, :pub_year, :string
    add_column :publications, :language, :string
  end
end
