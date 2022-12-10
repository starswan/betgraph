# frozen_string_literal: true
#
# $Id$
#
require_relative "boot"

require "rails"
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'active_job/railtie'
require 'action_mailer/railtie'
# action_cable/engine
# action_mailbox/engine
# action_text/engine
# rails/test_unit/railtie
# sprockets/railtie

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Bfrails4
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.autoload_paths << Rails.root.join("lib")
    config.autoload_paths << Rails.root.join("betfair")
    # config.autoload_paths << Rails.root.join('app', 'valuers')

    # Rails 5.1 - use eager_load_paths so that production doesn't break.
    config.eager_load_paths << Rails.root.join("lib")
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = "London"

    config.active_job.queue_name_prefix = "bfrails4.#{Rails.env}"
    config.active_job.queue_name_delimiter = "."

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    # config.active_record.raise_in_transactional_callbacks = true
  end
end
