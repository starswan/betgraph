# frozen_string_literal: true

class HalfTimeValuer
  def end_time
    45.minutes
  end

  def value_with_handicap(h, a, hs, as, _handicap)
    value h, a, hs, as
  end

  def final_value(match, home_value, away_value, _handicap)
    value home_value, away_value, match.result.half_time_home_score, match.result.half_time_away_score if match.result
  end

  # default in case not yet implemented
  def expected_value(_param1, _prices)
    OpenStruct.new(bid: nil, ask: nil)
  end
end
