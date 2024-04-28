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
gem "betfair-ng", require: "betfair"
# sadly net-http-persistent doesn't respect https_proxy env var
# so doesn't work on alice
gem "curb"

# rails 5.2 faster load times
gem "bootsnap"

# bootstrap 5.x
gem "bootstrap", "~> 5.3"

# Better charts than morris.js
gem "chartkick"
gem "clockwork"
# Use CoffeeScript for .coffee assets and views
gem "coffee-rails"
gem "config"
# turbo-charged counter caches https://github.com/magnusvk/counter_culture
gem "counter_culture", "~> 3.5"
gem "devise"
# environment variables in .env files
gem "dotenv-rails"
gem "faraday", ">= 2"
gem "faraday-retry"

gem "mysql2"

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder", "~> 2.11"
# Use jquery as the JavaScript library
# gem "jquery-rails"

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
gem "rails", "~> 7", "< 7.1"
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

# BZip 2 support
# neither of these 2 seem to work
# gem "ruby-bzs", require: "bzs"
# gem 'seven_zip_ruby'
# gem "bzip2-ffi"
gem "iostreams"
gem "bzip2-ffi"

gem "morrisjs-rails", git: "https://github.com/beanieboi/morrisjs-rails"
gem "raphael-rails"

# Ruby 3.x compatibility merged to master, but not released
# last published version v2.1.0.3 doesn't support Ruby 3
# we don't need this just yet...
# gem "gsl", git: "https://github.com/SciRuby/rb-gsl"
# dunno whether this is still any good?
# gem "newrelic_rpm"
# YAML database dump for postgres conversion attempt
# this gem possibly has issues on loading
# due to excess RAM usage - it can't save either
gem "yaml_db"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug"
  gem "capybara"
  gem "guard-bundler"
  gem "guard-rspec"
  gem "guard-rubocop"
  gem "rspec-rails"
  # Access an IRB console on exception pages or by using <%= console %> in views
  # gem 'web-console', '~> 2.0'
  gem "parallel_tests"

  gem "pronto"
  gem "pronto-rubocop"
  gem "pronto-undercover"
  gem "pry-rails"
  gem "puma"

  # bundle exec rake doc:rails generates the API under doc/api.
  gem "sdoc"
  # 4.11 insists that /usr/bin/firefox is a binary, when it isn't
  # on Ubuntu 22.04 due to it being a snap which is very annoying
  gem "selenium-webdriver", "< 4.11"

  # gem "spring"
  gem "undercover"
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
  gem "capistrano", "< 3"
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
  gem "simplecov-lcov", require: false
  gem "factory_bot_rails"
  # needed for rails 5.x and above
  gem "rails-controller-testing"

  gem "database_cleaner-active_record"
  gem "shoulda-matchers"
  gem "webmock"
  gem "vcr"
end
