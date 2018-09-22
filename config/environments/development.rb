Bybeconv::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true

  config.action_controller.perform_caching = false # generally desirable

  ## uncomment to test caching
  #config.action_controller.perform_caching = true # uncomment to test caching
  config.cache_store = :mem_cache_store


  # temp
  config.i18n.enforce_available_locales = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  #config.action_dispatch.best_standards_support = :builtin # disabled for Rails 4.x

  # Do not compress assets
  config.assets.js_compressor = false
  config.assets.digest = false
  # Expands the lines which load the assets
  config.assets.debug = true
  config.eager_load = false
  # config.public_file_server.enabled = true # Rails 5.x?
  config.i18n.available_locales = :he

  # Store Active Storage files locally.
  config.active_storage.service = :local

end
