Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false
  #OmniAuth.config.test_mode = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true

    # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :mem_cache_store, '127.0.0.1', {namespace: ENV['CACHE_NONCE'], value_max_bytes: 40*1024*1024}
    #config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  config.i18n.enforce_available_locales = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true

  config.action_mailer.smtp_settings = {
    address: "localhost",
    port: 25,
    domain: "benyehuda.org",
    openssl_verify_mode: 'none',
    disable_start_tls: true,
  }

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  #config.action_dispatch.best_standards_support = :builtin # disabled for Rails 4.x

  # Do not compress assets
  config.assets.js_compressor = false
  config.assets.digest = false
  # Expands the lines which load the assets
  config.assets.debug = false
  #config.assets.debug = true
  config.eager_load = false
  # config.public_file_server.enabled = true # Rails 5.x?
  config.i18n.available_locales = :he

  # Store Active Storage files locally.
  config.active_storage.service = :local
  #config.active_storage.service = :amazon
  #config.force_ssl = true # to debug SSL issues
  require "active_support/core_ext/integer/time"

  config.action_mailer.perform_caching = false

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true

  routes.default_url_options[:host] = 'localhost:3000'
  routes.default_url_options[:protocol] = 'https'

  if ENV['PROFILE']
    config.cache_classes = true
    config.eager_load = true

    config.logger = ActiveSupport::Logger.new(STDOUT)
    config.log_level = :info

    config.public_file_server.enabled = true
    config.public_file_server.headers = {
      'Cache-Control' => 'max-age=315360000, public',
      'Expires' => 'Thu, 31 Dec 2037 23:55:55 GMT'
    }
    config.assets.js_compressor = :uglifier
    config.assets.css_compressor = :sass
    config.assets.compile = false
    config.assets.digest = true
    config.assets.debug = false

    config.active_record.migration_error = false
    config.active_record.verbose_query_logs = false
    config.action_view.cache_template_loading = true
  end
end
