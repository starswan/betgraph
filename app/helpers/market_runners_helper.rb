module MarketRunnersHelper
  # :nocov:
  def runner_label(runner)
    if runner.bet_market.markettype.starts_with?("OVER_UNDER") || runner.bet_market.markettype.in?(%w[MATCH_ODDS])
      runner.runnername
    elsif runner.bet_market.markettype.in?(%w[CORRECT_SCORE CORRECT_SCORE2]) && runner.description.last.in?(%w[0 1 2 3 4 5 6 7])
      runner.description
    elsif (runner.bet_market.markettype.starts_with?("TEAM_A_") || runner.bet_market.markettype.starts_with?("TEAM_B_")) &&
        runner.description != "Draw" &&
        !runner.bet_market.markettype.ends_with?("TO_NIL")
      runner.description
    else
      "#{runner.bet_market.name} (#{runner.runnername})"
    end
  end
  # :nocov:
end
