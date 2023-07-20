source 'http://rubygems.org'

gem 'rails', '~> 6'
gem 'rails-i18n' # , git: 'https://github.com/svenfuchs/rails-i18n.git' # , branch: 'rails-4-x' # For 4.x
gem 'actionview'
gem 'sprockets', '~> 3' # 4.x requires switching to a manifest.js for assets
gem 'rails-ujs'
gem 'mysql2' # Rails 5.2 needs a newer one # , '~> 0.3.11'
gem 'omniauth-google-oauth2'
gem 'omniauth-twitter'
gem 'rufus-scheduler' # scheduler

gem 'chewy' # for ElasticSearch 7.x
gem 'active_data' # for *Search classes in Chewy

gem "jquery-slick-rails" # for carousel slider
gem 'rails-jquery-autocomplete', '>= 1.0.5' # for auto-completion
gem 'property_sets', '>= 3.7.1' # for key/value properties per model; version 3.7.1 supports Ruby 3.0 per https://github.com/zendesk/property_sets/issues/85
gem 'image_processing'
# gem "mini_magick", ">= 4.9.4" # now (Rails 6.1) required by image_processing
gem 'marcel', '~> 1'
gem "omniauth-rails_csrf_protection"

gem 'rack-cors', require: 'rack/cors'

gem 'diffy'
gem 'aws-sdk-s3' # for Active Storage

gem 'kt-paperclip', git: 'https://github.com/kreeti/kt-paperclip.git' # for Ruby 3.2 compatibility, until https://github.com/kreeti/kt-paperclip/pull/98 is officially released
#gem 'kt-paperclip', '7.1.1' # , '~>5.2' # for cloud files like author images 6.x requires aws >3.x
# gem 'impressionist' # latest released gem incompatible with Ruby 3.x
gem 'impressionist',
  git: 'https://github.com/charlotte-ruby/impressionist',
  ref: '46a582ff8cd3496da64f174b30b91f9d97e86643'
gem 'jbuilder', '~> 2.0' # for JSON APIs
gem 'sqlite3' # for dictionary imports
# gem 'rollbar' # error reporting. Airbrake replacement.

gem 'jquery-rails'
gem "jquery-ui-rails"
gem 'rdf' #, '~> 2.0.1'
gem 'sparql-client'#, '~> 2.0.1'
gem 'linkeddata' # for RDF etc.
gem 'rdf-vocab' # for SKOS predefined vocab
gem 'activerecord-session_store'
gem 'sass-rails'
gem 'coffee-script'
#gem "jquery-ui-rails", "~> 4.0.4"

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

gem 'client_side_validations'

gem 'execjs'
gem 'mini_racer'
gem 'htmlentities'
gem 'kaminari'
#gem 'kaminari', '1.1.1' # pagination. Kaminari 1.2.1 seems to have a bug - https://github.com/kaminari/kaminari/issues/1033
gem "nokogiri"

gem 'rmultimarkdown' # new wrapper over Fletcher Penney's MultiMarkDown 6 (MMD 6)
gem 'yt' # for polling YouTube for new videos

gem 'hebrew', '>= 0.2.1' # https://github.com/abartov/hebrew
gem 'gared', '>= 0.0.29' # https://gitlab.com/abartov/gared # for scraping bibliographic data from Hebrew sources
# gem 'goldiloader'
gem 'haml'
#gem 'zoom', '~>0.4.1', :git => 'https://github.com/bricestacey/ruby-zoom.git' # for Z39.50 queries to libraries
gem 'haml-rails'
gem 'project-honeypot2', '>= 0.1.3' # for HTTP:BL service by Project Honeypot
gem 'paper_trail' # for versioning entities
gem 'gepub' # for generating EPUBs
gem 'rmagick' # for generating cover images for EPUBs
gem 'pandoc-ruby' # for converting to DOCX
gem 'docx' # for pre-processing DOCX files to preserve stanzas
gem 'uglifier'
gem 'responders' # for respond_to at controller level (in api_controller)
# gem 'forty_facets' # for faceted search
gem 'better_sjr' # ease debugging of server-side JS responses
# gem 'histogram' # for histograms in date filter
gem 'momentjs-rails' # for date picker in filters
gem 'bootstrap4-datetime-picker-rails' # for date picker in filters
gem 'hebruby' # for Hebrew date handling

gem 'grape', '1.6.0' # 1.6.1 adds a Validators module damisul's patch isn't ready for
gem 'grape-entity', '~> 0.10.1'
# TODO: Replace to standard version of gem after PR will be accepted https://github.com/jagaapple/grape-extra_validators/pull/10
gem 'grape-extra_validators', '~> 2.1.0', git: "https://github.com/damisul/grape-extra_validators"
gem 'grape-swagger', '~> 1.4.2'
gem 'grape-swagger-entity', '~> 0.5.1'
gem 'rswag-api'
gem 'rswag-ui'
gem 'ahoy_matey' # for recording events
gem 'blazer' # for exploring Ahoy events

group :production do
  gem 'newrelic_rpm' # performance monitoring
  gem 'dalli'
  gem 'thin', git: 'https://github.com/macournoyer/thin.git' # 1.8.1 still doesn't support Ruby 3.2

  gem 'capistrano-thin', '~> 2.0.0'
end

group :test do
  gem 'turn', '0.8.2', require: false
  gem 'simplecov', require: false
  gem 'faker', '~> 2.19.0'
  gem 'rails-controller-testing', '~> 1.0.5'
#  gem 'thin'
end

group :development do
  gem 'byebug'
  gem 'web-console'
  gem "capistrano", "~> 3.11", require: false
  gem "capistrano-rails", "~> 1.4", require: false
  gem 'rvm1-capistrano3', require: false
  gem 'capistrano-rvm'
  gem 'listen'
  gem 'derailed_benchmarks', group: :development
#  gem 'bullet' # for suggestions to add/remove eager loading
  gem 'active_record_query_trace'
  gem 'immigrant'
  gem 'ruby-prof' # for profiling
  gem 'puma'
  gem 'ed25519'
  gem 'bcrypt_pbkdf'
end

group :test, :development do
  gem 'factory_bot_rails', '~> 6.2.0'
  gem 'rspec-rails', '~> 5.0.2'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'debug'
end
