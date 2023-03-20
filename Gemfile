# frozen_string_literal: true

#
# $Id$
#
# I have no secrets from the government about which gems are
# downloaded with this project, and this helps squid cache them
source "http://rubygems.org"

gem "activeadmin"
gem "actionpack-page_caching"
# This gem is needed for rails 5.1 to keep implicit XML serialization working
gem "activemodel-serializers-xml"
gem "acts_as_paranoid"
gem "acts_as_tree"
# can't remember why I pinned this
# gem "autoprefixer-rails", "< 10.0"
gem "autoprefixer-rails"

gem "backburner"
gem "backup-task"

# gem "betfair", path: "#{ENV['HOME']}/starswan.git/projects/betfair"

# rails 5.2 faster load times
gem "bootsnap"

# bootstrap 5.x
gem "bootstrap", "~> 5.2"

# Better charts than morris.js
gem "chartkick"
gem "clockwork"
# Use CoffeeScript for .coffee assets and views
gem "coffee-rails"
gem "config"
# turbo-charged counter caches https://github.com/magnusvk/counter_culture
gem "counter_culture", "~> 3.3"
gem "devise"
# environment variables in .env files
gem "dotenv-rails"
# github version fixes Ruby 2.4.x deprecation warning
gem "ezcrypto", git: "https://github.com/pglombardo/ezcrypto"
gem "faraday", ">= 2"
gem "faraday-retry"

gem "mysql2"

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.11"
# Use jquery as the JavaScript library
# gem "jquery-rails"

gem "jcnnghm-acts_as_secure"
gem "kaminari"

# attempt to bring data into postgres
# sudo su - postgres
# psql
# postgres=# create role rails with createdb login password '123rails!';
# needed to be able to alter constraints
# postgres=# alter user rails with superuser;
# can't get this to work on iMac yet
gem "pg"

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
# gem "rails", "~> 5.2.1"
gem "rails", "~> 6.1"
# Use SCSS for stylesheets
gem "sass-rails", "~> 6"
# Use Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"
gem "webpacker", ">= 5", "< 6"

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Passenger as the app server
gem "passenger", "~> 5.0"
# gem 'unicorn'

gem "rubyzip"

# YAML database dump for postgres conversion attempt
# this gem possibly has issues on loading
# due to excess RAM usage - it can't save either
gem "yaml_db"
gem "morrisjs-rails"
gem "raphael-rails"
# dunno whether this is still any good?
# gem "newrelic_rpm"
gem "iostreams"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug"
  gem "guard-bundler"
  gem "guard-rspec"
  gem "guard-rubocop"
  gem "rspec-rails"
  # Access an IRB console on exception pages or by using <%= console %> in views
  # gem 'web-console', '~> 2.0'

  gem "pry-rails"

  # bundle exec rake doc:rails generates the API under doc/api.
  gem "sdoc"

  # gem "spring"
end

group :development do
  # not sure if better_errors is working with Rails 6.0 and ruby 2.6
  # gem "better_errors"
  gem "binding_of_caller"

  # generators for bootstrap only needed during development
  gem "bootstrap-sass-extras"
  # needed for ed25519 key support
  gem "ed25519"
  gem "bcrypt_pbkdf"

  gem "bullet"

  # Use Capistrano for deployment
  gem "capistrano", "~> 2.15.8"
  gem "capistrano-ext"
  gem "capistrano-rails"
  gem "listen"
  gem "rvm-capistrano", require: false

  gem "rubocop-govuk"
  gem "rubocop-performance"
  gem "rack-mini-profiler"

  gem "rubycritic"
end

group :test do
  gem "timecop"
  gem "simplecov", require: false
  gem "factory_bot_rails"
  # needed for rails 5.x and above
  gem "rails-controller-testing"

  gem "database_cleaner-active_record"
  gem "shoulda-matchers"
  gem "webmock"
end
