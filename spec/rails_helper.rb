# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= "test"

if ENV["COVERAGE"]
  require "simplecov"
  require "simplecov-lcov"

  # This allows both LCOV and HTML formatting -
  # lcov for undercover gem and cc-test-reporter, HTML for humans
  class SimpleCov::Formatter::MergedFormatter
    def format(result)
      SimpleCov::Formatter::HTMLFormatter.new.format(result)
      SimpleCov::Formatter::LcovFormatter.new.format(result)
    end
  end

  SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
  # for cc-test-reporter after-build action
  SimpleCov::Formatter::LcovFormatter.config.output_directory = "coverage"
  # SimpleCov::Formatter::LcovFormatter.config.lcov_file_name = 'lcov.info'
  SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter

  SimpleCov.start :rails do
    enable_coverage :branch
    # primary_coverage :branch
    # ruby 3.2 needed
    # enable_coverage_for_eval

    add_filter "app/admin"
    add_filter "lib/tasks/db/yaml_load"
    # not really testable
    add_filter "app/jobs/keep_everything_alive_job.rb"
    add_filter "app/jobs/tickle_live_prices_job.rb"
    # Will go away some time real soon now
    add_filter "app/jobs/trigger_live_prices_job.rb"
    # not really testable
    add_filter "app/jobs/make_all_matches_job.rb"
    # not really testable
    add_filter "app/jobs/load_all_football_data_job.rb"
    add_filter "app/controllers/motor_races_controller.rb"
    add_filter "app/controllers/snooker_matches_controller.rb"
    add_filter "app/controllers/tennis_matches_controller.rb"
    add_filter "app/models/baseball_match.rb"
    add_filter "app/models/basketball_match.rb"
    add_filter "app/models/cricket_match.rb"
    add_filter "app/models/snooker_match.rb"
    add_filter "app/models/motor_race.rb"
    add_filter "app/models/team_division.rb"
    # not used yet
    add_filter "app/models/user.rb"
    # not used yet
    add_filter "app/valuers/poisson_sum.rb"
    add_group "Valuers", "app/valuers"
    add_group "Betfair", "../betfair2/lib"
    # minimum_coverage 86.96
    # setting primary branch coverage reduces us to this really low value
    # minimum_coverage 49.07
    minimum_coverage 88.92
    # we seem to have flakey/non-stable coverage values
    # maybe no longer...?
    maximum_coverage_drop 0.15
  end
end

require File.expand_path("../../config/environment", __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "spec_helper"
require "rspec/rails"
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  # config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.include(Shoulda::Matchers::ActiveModel, type: :model)
  config.include(Shoulda::Matchers::ActiveRecord, type: :model)

  config.before(:suite) do
    DatabaseCleaner.clean_with(:deletion)
  end

  config.before do
    DatabaseCleaner.strategy = :transaction
  end

  config.before do
    DatabaseCleaner.start
  end

  config.after do
    DatabaseCleaner.clean
  end

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end
