# frozen_string_literal: true

#
# $Id$
#
# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

# role :app, %w{deploy@example.com}
# role :web, %w{deploy@example.com}
# role :db,  %w{deploy@example.com}

require "rvm/capistrano"

set :deploy_to, "/home/pi/betgraph"
set :user, "pi"
set :rails_env, "pi"
set :rvm_ruby_string, "3.2.8@bg"
# Try to speed up ruby compilation on Raspberry Pi 2
# set :rvm_install_ruby_threads, 5
# need sudo as we are installing to /var/lib/gems on pi
# set :use_sudo, true
# set :rvm_type, :user

# append :linked_files, ".env.pi"
set :linked_files, fetch(:linked_files, []) << ".env.pi"

# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

# server 'example.com', user: 'deploy', roles: %w{web app}, my_property: :my_value
# server "pione", :db, :app, :web, primary: true
# server "pifour", :web, :app
# temp exclusion of pione to see if we can deploy on Raspberry PI 2 (rather than a 1.2)
# Takes 62 minutes to deploy on the pair
server "pifour", :web, :app, :db, primary: true

# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult[net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start).
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
#
# And/or per server (overrides global)
# ------------------------------------
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
