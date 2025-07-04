require_relative 'boot'

require 'rails/all'
require 'active_job'

# temp
# ActiveSupport::Deprecation.debug = true
if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups)
  # Bundler.require(*Rails.groups(:assets => %w(development test))) # line from Rails 3.2.x
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Bybeconv
  class Application < Rails::Application
    config.load_defaults 7.0

    # but use SHA1 for key generation, as in Rails 6.1, because there are links to storage objects embedded in markdown
    config.active_support.key_generator_hash_digest_class = OpenSSL::Digest::SHA1

    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    # load stuff from lib
    config.autoload_paths += %W(#{config.root}/lib)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = 'utf-8'

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # config.active_record.raise_in_transactional_callbacks = true # opting in to new behavior
    # config.active_job.queue_adapter = :inline # scheduler
    # config.active_job.queue_adapter = :delayed_job # scheduler
    config.active_job.queue_adapter = :sidekiq
    config.active_job.queue_name_prefix = Rails.env

    config.i18n.default_locale = :he
    config.i18n.available_locales = %i(he en)
    config.i18n.enforce_available_locales = true
    config.i18n.fallbacks = %i(he)

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', headers: :any, methods: %i(get post options)
      end
    end
    # BYBE's own configuration
    config.constants = config_for(:constants)
    if ENV['PROFILE'] == 'true'
      config.middleware.use Rack::RubyProf, path: './tmp/profile'
    end
  end
end
