# frozen_string_literal: true

#
# $Id$
#
Backburner.configure do |config|
  # close dead markets Needs to be higher than capture so that we don't try to capture dead things
  # PRIORITY_LABELS = {
  #     execute_trade: 10,
  #     close_dead_markets: 20,
  #     live_prices: 30,
  #     make_matches_and_runners: 40,
  #     keep_alive: 50,
  #     refresh_sport_list: 60,
  #     make_menu_paths: 70,
  #     make_runner_basket_items: 75,
  #     basket_valuer: 80,
  #     destroy_object: 85,
  #     load_football_data: 90,
  # }

  config.beanstalk_url = ["beanstalk://#{ENV['BEANSTALK_HOST']}"]
  config.tube_namespace = if Rails.env.test? || Rails.env.development?
                            "betgraph.#{Rails.env}"
                          else
                            "betgraph"
                          end
  config.namespace_separator = "."
  config.primary_queue = "default"
  config.logger = Rails.logger
  config.respond_timeout = 3600
  config.reserve_timeout = 3600
  config.max_job_retries = 20
  # config.on_error = lambda { |ex| Rails.logger.error(ex); ActiveRecord::Base.connection.reconnect! }
  config.on_error = ->(ex) { Rails.logger.error(ex); raise ex }

  # This caused a weird autoload error in Rails 6 - it's probably not needed
  # config.default_priority = ApplicationJob::OFFSET_PRI + 100
  # config.priority_labels = PRIORITY_LABELS.map { |k, v| [k, v + PRIORITY_OFFSET] }.to_h
end

module ActiveJob
  module QueueAdapters
    # == Backburner adapter for Active Job
    #
    # Backburner is a beanstalkd-powered job queue that can handle a very
    # high volume of jobs. You create background jobs and place them on
    # multiple work queues to be processed later. Read more about
    # Backburner {here}[https://github.com/nesquena/backburner].
    #
    # To use Backburner set the queue_adapter config to +:backburner+.
    #
    #   Rails.application.config.active_job.queue_adapter = :backburner
    #
    # using pri: here fixes a bug (in rails 4.2.10 and still present)
    # fixes a bug whereby the BackBurner queue adapter doesn't respect the priority
    # set either by label/string or integer on the job class. The adapter thinks that the 'JobWrapper'
    # class is the actual class for the job which needs to have a queue_priority method that returns
    # either a symbol/string or an actual priority.
    class BackburnerAdapter
      def enqueue(job) # :nodoc:
        # Backburner::Worker.enqueue job.class, [ job.serialize ], queue: job.queue_name
        Backburner::Worker.enqueue JobWrapper, [job.serialize], queue: job.queue_name, pri: job.class.queue_priority
      end

      def enqueue_at(job, timestamp) # :nodoc:
        delay = timestamp - Time.current.to_f
        # Backburner::Worker.enqueue job.class, [ job.serialize ], queue: job.queue_name, delay: delay
        Backburner::Worker.enqueue JobWrapper, [job.serialize], queue: job.queue_name, delay: delay, pri: job.class.queue_priority
      end
    end

    class JobWrapper # :nodoc:
      class << self
        def perform(job_data)
          Base.execute job_data
        end
      end
    end
  end
end
