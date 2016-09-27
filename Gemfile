source 'http://rubygems.org'

gem 'rails', '~> 4.2.5' # what blocks upgrading?

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'mysql2', '~> 0.3.11'
gem 'omniauth-google-oauth2'
gem 'omniauth-twitter'
gem 'clockwork' # scheduler

gem 'jquery-rails'
gem "jquery-ui-rails"
gem 'protected_attributes' # compatibility gem for 3.2.x-style attr_accessible
gem 'rdf', '~> 2.0.1'
gem 'sparql-client', '~> 2.0.1'
gem 'activerecord-session_store'
gem 'sass-rails'
gem 'coffee-script'
#gem "jquery-ui-rails", "~> 4.0.4"

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

gem 'execjs'
gem 'therubyracer'
gem 'thin'
gem 'htmlentities'
#gem 'will_paginate'
gem 'kaminari' # pagination
gem 'nokogiri'
#gem 'epubbery' # for epubs
gem 'rmultimarkdown' # new wrapper over Fletcher Penney's MultiMarkDown 4 (MMD 4)

#gem 'rpeg-multimarkdown', :github => 'djungelvral/rpeg-multimarkdown' # note: gem unmaintained, native part doesn't build under Ruby 2.1 -- may need updating the native part from the actual peg-multimarkdown implementation.

# To use debugger
#gem 'debugger'
#gem 'byebug'

gem 'app_constants' # anything more Railsy?
gem 'hebrew' # https://github.com/abartov/hebrew
gem 'haml'
#gem 'zoom', '~>0.4.1', :git => 'https://github.com/bricestacey/ruby-zoom.git' # for Z39.50 queries to libraries
gem 'haml-rails'
gem 'linkeddata' # for RDF etc.
gem 'rdf-vocab' # for SKOS predefined vocab
gem 'project-honeypot', '>= 0.1.3' # for HTTP:BL service by Project Honeypot
gem 'paper_trail', '~> 4.0.0' # for versioning entities
gem 'gepub' # for generating EPUBs
gem 'rmagick' # for generating cover images for EPUBs

group :test do
  gem 'turn', '0.8.2', :require => false
end

group :development do
  gem 'byebug'
  gem 'web-console', '~> 2.0'
end
