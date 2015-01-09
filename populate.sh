read -n1 -p "Press a key to begin the POPULATE step.  Remember this determines the period a new file is considered to have been added in, for the WHATSNEW process."
RAILS_ENV=production bundle exec rake populate
read -n1 -p "Press a key to continue to SEQUENCE step"
RAILS_ENV=production bundle exec rake sequence
read -n1 -p "Press a key to continue to BEHEAD step"
RAILS_ENV=production bundle exec rake behead
