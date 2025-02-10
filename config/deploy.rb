# config valid for current version and patch releases of Capistrano
lock "~> 3.19.2"

# set :application, "my_app_name"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# main details
set :application, "betgraph"
# role :web, "alice"
# role :app, "alice"
# role :db,  "alice", :primary => true
# role :local, "localhost", :primary => true

# Default value for :format is :airbrussh.
# set :format, :airbrussh
if ENV.key? "BRANCH"
  # set :scm, :git
  set :repo_url, "git@github.com:starswan/betgraph.git"
  set :branch, ENV.fetch("BRANCH")
else
  # repo details
  # set :scm, :subversion
  set :repo_url, "http://arthur/svn/starswan/trunk/projects/betgraph"
end

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", 'config/master.key'

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "vendor", "storage", "node_modules"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure

# namespace :bundler do
#   desc "Symlink bundled gems on each release"
#   task :symlink_bundled_gems do
#     on roles(:app) do
#       run "mkdir -p #{shared_path}/bundled_gems"
#       run "ln -nfs #{shared_path}/bundled_gems #{release_path}/vendor/bundle"
#     end
#   end
#
#   desc "Install for production"
#   task :install do
#     on roles(:app) do
#       execute "cd #{release_path} && bundle config set deployment true"
#       execute "cd #{release_path} && bundle config set without 'development test'"
#       execute "cd #{release_path} && bundle package && bundle install"
#     end
#   end
# end
namespace :yarn do
  task :install do
    on roles(:app) do
      execute "cd #{release_path} && yarn install --prod"
    end
  end
end

# after "deploy:updated", "bundler:symlink_bundled_gems"
before "deploy:assets:precompile", "yarn:install"
