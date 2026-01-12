# frozen_string_literal: true

#
# $Id$
require "capistrano/ext/multistage"
require "whenever/capistrano"

set :stages, %w(alice pi arthur dell)
set :default_stage, "arthur"
set :linked_dirs, %w{node_modules}

# set :rvm_ruby_string, '2.2.4'
# set :rvm_type, :user
# this is deprecated in bundler 2.2.x
# set :bundle_without, %i[development test]
# set :rvm_install_type, '1.26.10'
# Using distcc this number can maybe go higher
# set :rvm_install_ruby_threads, 3

# main details
set :application, "betgraph"
# role :web, "alice"
# role :app, "alice"
# role :db,  "alice", :primary => true
# role :local, "localhost", :primary => true

# server details
# default_run_options[:pty] = true
# ssh_options[:forward_agent] = true
# set :deploy_to, "/home/starswan/html/bfrails4"
set :deploy_via, :copy
# set :user, "starswan"
set :use_sudo, false

if ENV.key? "BRANCH"
  set :scm, :git
  set :repository, "git@github.com:starswan/betgraph.git"
  set :branch, ENV.fetch("BRANCH")
else
  # repo details
  set :scm, :subversion
  set :repository, "http://arthur/svn/starswan/trunk/projects/betgraph"
end

# runtime dependencies
# depend :remote, :gem, "bundler", ">=1.0.0.rc.2"

# tasks
namespace :deploy do
  task :start, roles: :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  task :stop, roles: :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, roles: :app do
    run "touch #{current_path}/tmp/restart.txt"
    run "#{current_path}/prog_stop.sh clock"
    run "#{current_path}/prog_stop.sh queue"
    run "#{current_path}/prog_stop.sh queue2"
    run "#{current_path}/prog_stop.sh queue3"
    # run "#{current_path}/prog_stop.sh queue4"
    # Wakey wakey monit, work to do...
    run "monit reload"
  end

  desc "Symlink shared resources on each release"
  task :symlink_shared, roles: :app do
    # run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    fetch(:linked_files, []).each do |f|
      run "ln -nfs #{shared_path}/#{f} #{release_path}/#{f}"
    end
  end
end

after "deploy:update_code", "deploy:symlink_shared"

namespace :bundler do
  desc "Symlink bundled gems on each release"
  task :symlink_bundled_gems, roles: :app do
    run "mkdir -p #{shared_path}/bundled_gems"
    run "ln -nfs #{shared_path}/bundled_gems #{release_path}/vendor/bundle"
  end

  desc "Install for production"
  task :install, roles: :app do
    run "cd #{release_path} && bundle config set without 'development test'"
    run "cd #{release_path} && bundle install"
    run "chmod 600 #{release_path}/monitrc.arthur"
  end
end

namespace :yarn do
  task :install, roles: :app do
    run "cd #{release_path} && yarn install --prod"
  end
end

after "deploy:update_code", "bundler:symlink_bundled_gems"
before "deploy:assets:symlink", "bundler:install"
before "deploy:assets:precompile", "yarn:install"
after "deploy:update_code", "deploy:migrate"
