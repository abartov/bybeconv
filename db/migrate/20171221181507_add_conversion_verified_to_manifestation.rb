class AddConversionVerifiedToManifestation < ActiveRecord::Migration[4.2]
  def change
    puts "Adding conversion_verified field"
    add_column :manifestations, :conversion_verified, :boolean
    puts "setting to false"
    Manifestation.update_all(conversion_verified: false)
  end
end
