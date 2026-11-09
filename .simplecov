# default to coverage 'on' (e.g. for guard)
if ENV.fetch("COVERAGE", 1).to_i.positive?
  require "simplecov"

  SimpleCov.configure do
    enable_coverage :branch

    # Active Admin helpers
    %w[calendars competitions dashboard divisions football_divisions seasons sports team_total_configs].each do |f|
      skip "app/admin/#{f}.rb"
    end

    skip "lib/tasks/db/yaml_load"
    # not really testable
    skip "app/jobs/keep_everything_alive_job.rb"
    skip "app/jobs/tickle_live_prices_job.rb"
    # Will go away some time real soon now
    skip "app/jobs/trigger_live_prices_job.rb"
    # not really testable
    skip "app/jobs/make_all_matches_job.rb"
    # not really testable
    skip "app/jobs/load_all_football_data_job.rb"
    # Needs tests, but input data hard to understand. Code mostly empiricaL.
    skip "app/jobs/download_historical_data_file_job.rb"
    skip "app/controllers/tennis_matches_controller.rb"
    skip "app/models/baseball_match.rb"
    skip "app/models/basketball_match.rb"
    skip "app/models/cricket_match.rb"
    skip "app/models/snooker_match.rb"
    skip "app/models/motor_race.rb"
    skip "app/models/team_division.rb"
    # not used yet
    skip "app/models/user.rb"
    # not used yet
    skip "app/valuers/poisson_sum.rb"
    group "Valuers", "app/valuers"

    # flakey soverage files
    skip "app/views/tables/_menu.html.erb"
    skip "app/helpers/seasons_helper.rb"

    primary_coverage :branch
    minimum_coverage line: 10.74, branch: 4.68

    formats :html, :baseline
  end
end
