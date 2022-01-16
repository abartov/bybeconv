class AddStatusToPerson < ActiveRecord::Migration[5.2]
  def change
    add_column :people, :status, :integer
    add_column :people, :published_at, :datetime
    puts "Marking all existing people as :published."
    Person.update_all(status: :published)
    puts "Setting people's published_at to their created_at, as a rough estimate..."
    Person.all.each do |p|
      p.published_at = p.created_at
      p.save!
    end
    puts "...done!"
    add_index :people, [:status, :published_at]
  end
end
