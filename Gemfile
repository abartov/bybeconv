source 'http://rubygems.org'

gem 'rails', '~> 5.2.1'
gem 'rails-i18n', git: 'https://github.com/svenfuchs/rails-i18n.git' # , branch: 'rails-4-x' # For 4.x

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'mysql2' # Rails 5.2 needs a newer one # , '~> 0.3.11'
gem 'omniauth-google-oauth2'
gem 'omniauth-twitter'
#gem 'clockwork' # scheduler
#gem 'protected_attributes' # compatibility gem for 3.2.x-style attr_accessible
gem 'rufus-scheduler' # scheduler

gem 'chewy' # for ElasticSearch
gem 'active_data' # for *Search classes in Chewy

#gem 'jssorslider-rails', github: 'matthias-g/jssorslider-rails' # for carousel slider
gem "jquery-slick-rails" # for carousel slider
gem 'rails-jquery-autocomplete' # for auto-completion
gem 'property_sets' # for key/value properties per model
gem "font-awesome-rails"
#gem 'font-awesome-sass', '~> 4.7.0'
gem 'mini_magick'
gem 'rack-cors', require: 'rack/cors'

gem 'diffy'
# gem 'aws-sdk', '~>2.9' # for the Amazon cloud.  3.x breaks somehow. TBD: figure it out -- remove when migrating away from paperclip
gem 'aws-sdk-s3' # for Active Storage

gem 'paperclip' # , '~>5.2' # for cloud files like author images 6.x requires aws >3.x
gem 'impressionist' # for pageview stats
gem 'jbuilder', '~> 2.0' # for JSON APIs

gem 'rollbar' # error reporting. Airbrake replacement.

gem 'jquery-rails'
gem "jquery-ui-rails"
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
gem 'kaminari' # pagination
gem 'nokogiri'
#gem 'epubbery' # for epubs
gem 'rmultimarkdown' # new wrapper over Fletcher Penney's MultiMarkDown 6 (MMD 6)

#gem 'rpeg-multimarkdown', :github => 'djungelvral/rpeg-multimarkdown' # note: gem unmaintained, native part doesn't build under Ruby 2.1 -- may need updating the native part from the actual peg-multimarkdown implementation.

# To use debugger
#gem 'byebug'

gem 'app_constants' # anything more Railsy?
gem 'hebrew', '>= 0.2.0' # https://github.com/abartov/hebrew
gem 'gared', '>= 0.0.19' # https://gitlab.com/abartov/gared # for scraping bibliographic data from Hebrew sources

gem 'haml'
#gem 'zoom', '~>0.4.1', :git => 'https://github.com/bricestacey/ruby-zoom.git' # for Z39.50 queries to libraries
gem 'haml-rails'
gem 'linkeddata' # for RDF etc.
gem 'rdf-vocab' # for SKOS predefined vocab
gem 'project-honeypot2', '>= 0.1.3' # for HTTP:BL service by Project Honeypot
gem 'paper_trail', '~> 5.0.0' # for versioning entities
#gem 'gepub' # for generating EPUBs
gem 'gepub', '~> 0.7.0beta4' # for generating EPUBs
gem 'rmagick' # for generating cover images for EPUBs
gem 'pandoc-ruby' # for converting to DOCX
gem 'docx' # for pre-processing DOCX files to preserve stanzas
gem 'uglifier'
gem 'responders' # for respond_to at controller level (in api_controller)

group :production do
  gem 'newrelic_rpm' # performance monitoring
  gem 'dalli'
end

group :test do
  gem 'turn', '0.8.2', :require => false
  gem 'simplecov', require: false
end

group :development do
  gem 'byebug'
  gem 'web-console', '~> 2.0'
  gem "capistrano", "~> 3.11", require: false
  gem "capistrano-rails", "~> 1.4", require: false
  gem 'rvm1-capistrano3', require: false
  gem 'capistrano-thin', '~> 2.0.0'

end
