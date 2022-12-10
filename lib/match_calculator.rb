# frozen_string_literal: true

class MatchCalculator
  class << self
    # work out some correlations between actuals e.g current 0-0 is just a limited version of over/under goals
    # for match bb:
    #   how does this: (where 14 can be any number from 1 to 20)
    #   correlate with the actual bb.homescore + bb.awayscore?
    #   if x < (bb.homescore + bb.awayscore) * 14, what odds do we need to predict the over/under?
    #   [0-0 data showed that it was a good predictor of 1-0 home wins too, better than the 7-1 typically offered]
    def things(match_groups)
      2.upto(30).map { |limit|
        # things = [7, 11, 14, 16, 25, 4].map do |limit|
        # list of matches with a valid 'history' for all(both) teams
        history = match_groups.map { |match_list|
          match_list.map { |match|
            team_history = match.teams.map do |team|
              prev = match_list.select { |m| m.kickofftime < match.kickofftime && m.teams.include?(team) }.take(limit)
              { sum: prev.sum { |r| r.result.homescore + r.result.awayscore }, count: prev.size }
            end
            team_history.reduce(sum: 0, count: 0) { |r, ts|
              { sum: r.fetch(:sum) + ts.fetch(:sum), count: r.fetch(:count) + ts.fetch(:count) }
            }.merge(actual: match.result.homescore + match.result.awayscore, limit: limit * team_history.size)
          }.select { |h| h.fetch(:count) == h.fetch(:limit) }.map { |x| x.except(:count, :limit) }
        }.reduce(:+)
        lowest = history.min_by { |h| h.fetch(:sum) }.fetch(:sum)
        highest = history.max_by { |h| h.fetch(:sum) }.fetch(:sum)
        # puts [lowest, highest].inspect
        # what I'm looking for is the best threshold(s) for predicting the actual from the sum
        # try the simple case N = 0 (the nil-nil predictor) first
        results = lowest.upto(highest).map { |threshold|
          correct = history.count { |m| m.fetch(:sum) <= threshold && m.fetch(:actual) == 0 }
          wrong = history.count { |m| m.fetch(:sum) <= threshold && m.fetch(:actual) != 0 }
          # want to sort by biggest possible profit - so assume 17/2 odds
          profit = 8.5 * correct - wrong
          { limit: limit, correct: correct, wrong: wrong, threshold: threshold, profit: profit }
        }.sort_by { |j| j.fetch(:profit) }
        results.last
      }.select { |z| z.fetch(:profit) > 0 }.sort_by { |r| r.fetch(:profit) }
    end
  end
end
