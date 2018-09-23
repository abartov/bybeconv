class AddYearAndLanguageToPublication < ActiveRecord::Migration
  def change
    add_column :publications, :pub_year, :string
    add_column :publications, :language, :string
  end
end
