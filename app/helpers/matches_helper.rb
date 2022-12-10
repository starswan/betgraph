# frozen_string_literal: true

module MatchesHelper
  def markets_count(match)
    filled_in_markets = match.bet_markets.reject { |bm| bm.market_runners.empty? }
    "#{match.bet_markets_count} (#{filled_in_markets.count})"
  end
end
