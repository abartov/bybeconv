require 'rufus-scheduler'

scheduler = Rufus::Scheduler::singleton

# jobs go here

scheduler.every '24h' do
  puts "calculating popular works..."
  Manifestation.recalc_popular
  puts "calculating popular authors..."
  Person.recalc_popular
end
