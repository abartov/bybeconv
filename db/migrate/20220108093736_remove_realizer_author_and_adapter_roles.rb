class RemoveRealizerAuthorAndAdapterRoles < ActiveRecord::Migration[5.2]
  def change
    # removing author (0) and adapter (4) roles from realizers table
    # we didn't had any adapters in db, but additing them to script for clarity
    execute 'delete from realizers where role in (0, 4)'
  end
end
