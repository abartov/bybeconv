require 'rufus-scheduler'

scheduler = Rufus::Scheduler::singleton

# jobs go here

# daily stats
scheduler.every '24h' do
  puts "calculating popular works..."
  Manifestation.recalc_popular
  puts "calculating popular authors..."
  Person.recalc_popular
  puts "calculating recommendation counts..."
  Person.recalc_recommendation_counts
end

# slow maintenance reports
scheduler.every '7d' do
  puts "generating list of works with suspected typos"
  Manifestation.update_suspected_typos_list
  puts "generating list of bib publications that may already be in the system"
  Publication.update_publications_that_may_be_done_list
end