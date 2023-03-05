# config valid for current version and patch releases of Capistrano
#lock "~> 3.11.0"

set :application, "ProjectBenYehuda"
set :repo_url, "git@github.com:abartov/bybeconv.git"

# Default branch is :master
ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/bybe/bybeconv_staging"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, "config/database.yml", "config/s3.yml", "config/constants.yml", "config/storage.yml", "config/thin.yml", "config/chewy.yml"

append :linked_dirs, '.bundle', 'log', 'tmp/cache', 'public/system', 'tmp/pids', 'tmp/sockets'

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, {  }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

set :rvm1_ruby_version, "3.2.1"
#set :rvm1_ruby_version, "2.6.6"
#set :rvm1_ruby_version, "2.5.1"
before 'deploy', 'rvm1:alias:create'
after 'deploy:publishing', 'thin:restart'

namespace :debug do
  desc 'Print ENV variables'
  task :env do
    on roles(:app), in: :sequence, wait: 5 do
      execute :printenv
    end
  end
end
