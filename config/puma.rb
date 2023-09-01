app_dir = File.expand_path("../..", __FILE__)
shared_dir = "#{app_dir}"
rackup(File.expand_path('../config.ru', __dir__))
if ENV['RACK_ENV'] == 'production'
  require 'puma/daemon'
  environment 'production'
  workers Integer(ENV['WEB_CONCURRENCY'] || 3)
  daemonize
  bind "unix://#{shared_dir}/tmp/sockets/puma.sock"
  stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true
else
  workers 0
  environment 'development'
end

threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
threads 1, threads_count

preload_app!

# port        ENV['PORT']     || 3000
pidfile "#{shared_dir}/tmp/pids/puma.pid"


