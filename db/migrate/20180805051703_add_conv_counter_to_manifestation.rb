class AddConvCounterToManifestation < ActiveRecord::Migration[4.2]
  def change
    add_column :manifestations, :conv_counter, :integer
    puts "setting counters to 0"
    Manifestation.update_all conv_counter: 0
    puts "indexing..."
    add_index :manifestations, :conv_counter

  end
end
