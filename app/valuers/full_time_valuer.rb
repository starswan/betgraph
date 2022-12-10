# frozen_string_literal: true

class FullTimeValuer
  def end_time
    90.minutes
  end

  def value_with_handicap(h, a, hs, as, _handicap)
    value h, a, hs, as
  end

  def final_value(match, home_value, away_value, handicap)
    value_with_handicap home_value, away_value, match.result.homescore, match.result.awayscore, handicap if match.result
  end

  # default in case it's not implemented yet
  def expected_value(_param1, _prices)
    OpenStruct.new(bid: nil, ask: nil)
  end
end
