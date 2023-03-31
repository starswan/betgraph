# frozen_string_literal: true

class FixupCloseMarketPriceTimes < ActiveRecord::Migration[6.1]
  TIME_THRESHOLD = 20

  def up
    Match.includes(bet_markets: { market_runners: { market_prices: :market_price_time } }).with_prices.find_each(batch_size: 10) do |match|
      done = process_match(match).size
      if done.positive?
        say_with_time "#{Time.zone.now} #{match.division.name} #{match.kickofftime.to_s(:long)}: #{match.name}, #{done}" do
          while done.positive?
            done = process_match(match).size
            Rails.logger.info "#{Time.zone.now} #{match.division.name} #{match.kickofftime.to_s(:long)}: #{match.name}, #{done}"
          end
        end
      end
    end
    # fixup counts for MarketPriceTimes as we're using update_all for speed
    count = MarketPriceTime.count
    index = 0
    mpt_batch_size = 1000
    MarketPriceTime.find_in_batches(batch_size: mpt_batch_size).each do |batch|
      say_with_time "MarketPriceTime #{index}/#{count}" do
        batch.each { |mpt| MarketPriceTime.reset_counters(mpt.id, :market_prices) }
      end
      index += mpt_batch_size
    end
    MarketPriceTime.where(market_prices_count: 0).delete_all
    MarketPrice.counter_culture_fix_counts
  end

  def down; end

private

  def process_match(match)
    # 5 appears to be optimal
    # English Premier League May 05, 2017 20:00: West Ham v Tottenham, 108sec(ish)
    # German Bundesliga 1 May 06, 2017 14:30: Ingolstadt v Leverkusen, 482
    #    -> 186.8197s
    Match.transaction do
      process_in_groups_of(match, 5)
      match_prices(match).each_cons(2).select { |back, front| filtered?(back, front) }.each do |back, front|
        clashes = MarketPrice.where(market_price_time_id: back.market_price_time.id).map(&:market_runner_id)
        if front.market_runner_id.in? clashes
          front.destroy!
        else
          MarketPrice.where(id: front.id).update_all(market_price_time_id: back.market_price_time.id)
        end
      end
    end
  end

  def process_in_groups_of(match, group_size)
    match_prices(match).in_groups_of(group_size).each do |group|
      first = group.first
      tail = group.last(group_size - 1)
      next unless tail.all? { |g| filtered?(first, g) }

      clashes = MarketPrice.where(market_price_time_id: first.market_price_time.id).map(&:market_runner_id)
      # The same runner may be in 'tail' twice, so updating it with the same MPT would result in an error
      update_ids = tail.uniq(&:market_runner_id).reject { |t| t.market_runner_id.in? clashes }.map(&:id)
      # Rails.logger.debug("Clashes #{clashes} Tail #{tail.map(&:market_runner_id)} Updates #{update_ids}")
      # We can't update the clashes, so we just have to get rid of them.
      tail.select { |t| t.market_runner_id.in? clashes }.each(&:destroy)
      MarketPrice.where(id: update_ids).update_all(market_price_time_id: first.market_price_time.id)
    end
  end

  def match_prices(match)
    MarketPrice.includes(:market_price_time)
      .where(id: match.market_prices.map(&:id))
      .sort_by { |mp| mp.market_price_time.time }
  end

  def filtered?(back, front)
    back.present? &&
      front.present? &&
      (back.market_price_time != front.market_price_time) &&
      (front.market_price_time.time - back.market_price_time.time < TIME_THRESHOLD)
  end
end
