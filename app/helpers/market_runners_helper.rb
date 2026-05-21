module MarketRunnersHelper
  def runner_label(runner)
    if runner.bet_market.markettype.starts_with?("OVER_UNDER") || runner.bet_market.markettype.in?(["MATCH_ODDS", "CORRECT_SCORE", "CORRECT_SCORE2"])
      runner.runnername
    else
      "#{runner.bet_market.name} (#{runner.runnername})"
    end
  end
end