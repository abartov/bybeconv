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
  # config.cache_store = :mem_cache_store, { 'localhost', AppConstants.cache_nonce
  config.cache_store = :dalli_store, '127.0.0.1', {namespace: ENV['CACHE_NONCE'], value_max_bytes: 40*1024*1024}
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
  #config.active_storage.service = :amazon
  #config.force_ssl = true # to debug SSL issues

  #### Bullet settings for performance optimization
  config.after_initialize do
    Bullet.enable = true
    #Bullet.sentry = true
    Bullet.alert = true
    Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.growl = false
    #Bullet.xmpp = { :account  => 'bullets_account@jabber.org',                     :password => 'bullets_password_for_jabber',                     :receiver => 'your_account@jabber.org',                     :show_online_status => true }
    Bullet.rails_logger = true
    Bullet.honeybadger = false
    Bullet.bugsnag = false
    Bullet.appsignal = false
    Bullet.airbrake = false
    Bullet.rollbar = false
    Bullet.add_footer = true
    Bullet.skip_html_injection = false
    #Bullet.stacktrace_includes = [ 'your_gem', 'your_middleware' ]
    #Bullet.stacktrace_excludes = [ 'their_gem', 'their_middleware', ['my_file.rb', 'my_method'], ['my_file.rb', 16..20] ]
    #Bullet.slack = { webhook_url: 'http://some.slack.url', channel: '#default', username: 'notifier' }
  end
end
