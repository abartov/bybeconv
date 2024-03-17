Sidekiq.configure_server do |config|
  config.logger = Sidekiq::Logger.new($stdout)
end