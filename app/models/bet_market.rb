#
# $Id$
#
class BetMarket < ApplicationRecord
  # soft delayed background deletes - could cascade and take ages
  acts_as_paranoid
  # the 'active' flag is set false either by the market type being inactive (due to it being new)
  # if runners get deleted then the 'deleted' flag is set
  # 17-Oct-2015 Betfair started producing blank markettypes for next goalscorer - 2nd and 3rd (and 4th...) goals

  belongs_to :betfair_market_type, inverse_of: :bet_markets, optional: true
  belongs_to :match, inverse_of: :bet_markets, counter_cache: true
  has_many :market_runners, inverse_of: :bet_market, dependent: :destroy

  # Our relationships are bet_market -> market_price_time(s) -> market_price(s) -> market_runner(s)
  # has_many :market_prices, through: :market_price_times
  # its actually bet_market -> market_runner(s) -> market_price(s)
  # This alias causes more problems than it solves, as we often want to navigate back to the runner
  # has_many :market_prices, through: :market_runners
  has_many :trades, through: :market_runners

  CLOSED = "CLOSED".freeze
  ACTIVE = "ACTIVE".freeze
  OPEN = "OPEN".freeze
  SUSPENDED = "SUSPENDED".freeze

  validates :status, inclusion: { in: [CLOSED, ACTIVE, OPEN, SUSPENDED], nil: false }

  validates :marketid, uniqueness: { scope: :deleted_at }

  validates :number_of_runners, :marketid, :time, presence: true
  validates :name, presence: true, uniqueness: { scope: [:match, :deleted_at] }

  # mark historical data loads so that they don't get culled due to holes in the data
  validates :price_source, inclusion: { in: %w[RestAPI HistoricalData], allow_nil: false }
  scope :api_priced, -> { where(price_source: "RestAPI") }
  scope :with_historical_prices, -> { where(price_source: "HistoricalData") }

  # Yes some of these markets aren't strictly 'Asian Handicap' markets but they behave like it
  # for pricing purposes i.e. each runner has a 'handicap' value associated with it.
  # Goals markets are often just the number e.g. 7 goals === handicap 7
  # no idea whats going on with the shown a card thing though...
  ASIAN_MARKET_TYPES = %w[A
                          ASIAN_HANDICAP
                          TOTAL_GOALS
                          TEAM_TOTAL_GOALS
                          ALT_TOTAL_GOALS].freeze

  NO_WINNER_TYPES = %w[ANYTIME_ASSIST
                       SHOWN_A_CARD
                       PLAYER_FOULS_1
                       PLAYER_FOULS_2
                       TO_SCORE
                       TO_SCORE_2_OR_MORE
                       TO_SCORE_HATTRICK
                       SHOTS_ON_TARGET_P1
                       SHOTS_ON_TARGET_P2
                       SHOTS_ON_TARGET_P3
                       MATCH_SHOTS
                       MATCH_SHOTS_TARGET].freeze

  scope :by_active_and_name, -> { order(active: :desc, name: :asc) }

  scope :by_betfair_market_id, lambda { |marketid|
    exchange_id, market_id = marketid.split(".")
    where exchange_id: exchange_id, marketid: market_id
  }

  scope :active, lambda {
    joins(:match)
      .includes(:match)
      .merge(Match.almost_live)
      .not_closed
      .order(:time)
  }

  scope :live, lambda {
    where(live: true, active: true)
      .joins(:match)
      .not_closed
      .merge(Match.live_priced)
  }

  scope :activelive, lambda {
    where(live: true, active: true)
      .joins(:match)
      .not_closed
      .merge(Match.almost_live.live_priced)
      .includes(:match, :market_runners)
      .order(:time)
  }

  scope :active_status, -> { where(active: true) }
  scope :closed, -> { where(status: CLOSED) }
  scope :not_closed, -> { where.not(status: CLOSED) }
  scope :not_closed_or_suspended, -> { where.not(status: [CLOSED, SUSPENDED]) }

  scope :asian_handicap, -> { where(markettype: ASIAN_MARKET_TYPES) }

  scope :half_time, -> { joins(:betfair_market_type).merge(BetfairMarketType.half_time) }
  scope :full_time, -> { joins(:betfair_market_type).merge(BetfairMarketType.full_time) }

  delegate :half_time?, to: :betfair_market_type

  def sport
    match.division.calendar.sport
  end

  def asian_handicap?
    markettype.in? ASIAN_MARKET_TYPES
  end

  before_create do |betmarket|
    betmarket.betfair_market_type = betmarket.find_market_type
    betmarket.active = betmarket.betfair_market_type.active
    betmarket.description = betmarket.name
  end

  before_update do |bm|
    if bm.active && (bm.betfair_market_type.nil? || bm.match.nil? || bm.betfair_market_type.sport != bm.match.division.calendar.sport)
      bm.betfair_market_type = bm.find_market_type
    end
  end

  def betfair_marketid
    "#{exchange_id}.#{marketid}"
  end

  # This guy needs to collect all the runners price data for the current time
  # and then invoke the market valuer with market_param, [runner_params] where
  # runner_params are runner_value(from BetfairRunnerType), backprice, layprice
  # This would allow e.g. overundergoals to know that it was a 2-runner market and ignore the 2 worst prices of the 4.
  def expected_value(actualtime)
    prices = market_prices_at(actualtime)
    if prices.any?
      # Each price implies a value of lambda (expected value of market)
      rvs = prices.map do |price|
        # runner = price.market_runner
        runner = market_runners.detect { |mr| mr.id == price.market_runner_id }
        # BetfairMarketType::ExpectedPrice.new home: runner.betfair_runner_type.runnerhomevalue,
        #                                      away: runner.betfair_runner_type.runnerawayvalue,
        #                                      handicap: runner.handicap,
        #                                      price: price.back1price

        { homevalue: runner.betfair_runner_type.runnerhomevalue.to_f,
          awayvalue: runner.betfair_runner_type.runnerawayvalue.to_f,
          handicap: runner.handicap.to_f,
          # TODO: - this should be dependent on an amount, and reflect the prices available.
          backprice: price.back_price.to_f,
          layprice: price.lay_price.to_f }
      end
      betfair_market_type.expected_value(rvs)
    else
      OpenStruct.new(bid: nil, ask: nil)
    end
  end

  def market_value(actualtime, homescore, awayscore)
    total = 0
    neg_total = 0
    prob = 0
    neg_prob = 0
    implied_prob = 1
    implied_neg_prob = 1
    prices = market_prices_at(actualtime)
    if prices.any?
      # Each of market_prices has a runner, backprice and layprice
      prices.each do |price|
        # Each price implies a value of lambda (expected value of market)
        backprice = price.back_price
        layprice = price.lay_price

        runner = market_runners.detect { |mr| mr.id == price.market_runner_id }

        # runner_value returns 1 if runner would win, 0 if runner is a push and -1 otherwise
        # possibly scaled e.g. asians can return fractional answers.
        runner_value = runner.runner_value homescore, awayscore
        logger.debug "MP: #{homescore}-#{awayscore} #{runner.runnername} #{backprice.to_f} #{layprice.to_f} #{runner_value}"

        total += runner_value / backprice if runner_value > 0 && backprice
        prob += 1 / backprice if backprice
        implied_prob = total / prob if prob > 0

        neg_total += -runner_value / layprice if runner_value < 0 && layprice
        neg_prob += 1 / layprice if layprice
        implied_neg_prob = 1 - neg_total / neg_prob if neg_prob > 0
      end
      logger.debug format("VAL: #{name} #{homescore} #{awayscore} IP [%.2f] INP [%.2f] P [%.2f] NP [%.2f]", implied_prob, implied_neg_prob, prob, neg_prob)
    end
    # Choose lowest implied probability as it implies best price
    # probability = [implied_neg_prob,implied_prob].min
    # probability < 0.001 ? 0 : 1 / probability
    total > 0 ? total : neg_total
  end

  def open?
    status != CLOSED
  end

  def winners
    if betfair_market_type.active
      active_runners = market_runners.reject { |runner| runner.final_runner_value.nil? || runner.final_runner_value < 0 }
      winners = active_runners[0..0]
    else
      winners = []
    end
    if winners.empty?
      if match.prices.empty?
        runners = market_runners.order(:sortorder)
      else
        runners = market_runners.map(&:prices).flatten
                                .sort_by { |p| p.lay_price.present? ? -1 / p.lay_price : (p.back_price.presence || 0) }
                                .map(&:market_runner).uniq
      end
      runners[0..0]
    else
      winners
    end
  end

  def find_market_type
    # eventdescription = menu_path.name[-1]
    # vs = eventdescription.index(' v ')
    marketname = name.dup
    # if vs != nil
    #   hometeam, awayteam = eventdescription[0..vs], eventdescription[vs+3..-1]
    #   marketname.gsub! hometeam, '#{hometeam}'
    #   marketname.gsub! awayteam, '#{awayteam}'
    # end
    if match.teams.count == 2
      hometeamname = match.hometeam.team_names.map(&:name)
                          .select { |name| marketname.include?(name) }
                          .max_by(&:length)
      awayteamname = match.awayteam.team_names.map(&:name)
                          .select { |name| marketname.include?(name) }
                          .max_by(&:length)
      marketname.gsub! hometeamname, '#{hometeam}' if hometeamname
      marketname.gsub! awayteamname, '#{awayteam}' if awayteamname
    end
    # Do a sequential serial find allowing interpolation to take place
    interpolatedname = marketname.gsub '\#', "#"
    # sport.betfair_market_types.each do |markettype|
    #  if markettype.name == interpolatedname
    #    bmtype = markettype
    #    break
    #  end
    # end
    # bmtype = sport.betfair_market_types.find { |markettype| markettype.name == interpolatedname }
    # #if bmtype.nil?
    # #  bmtype = sport.betfair_market_types.create! :name => marketname, :valuer => marketname
    # #end
    # bmtype ||= sport.betfair_market_types.create! :name => marketname, :valuer => marketname, active: false
    # bmtype
    # Need to create market_type inactive to prevent crashes on non-existent valuers
    sport.betfair_market_types.find { |markettype| markettype.name == interpolatedname } ||
      sport.betfair_market_types.create!(name: marketname, valuer: marketname, active: false)
  end

private

  def market_prices_at(time)
    # price_query = MarketPrice.where(market_runner: market_runners)
    # price_query.joins(:market_price_time)
    #   .merge(MarketPriceTime.later_than(time))
    #   .uniq(&:market_runner)
    price_query = Price.where(market_runner_id: market_runners.map(&:id))
    price_query.merge(Price.later_than(time)).uniq(&:market_runner_id)
  end
end
