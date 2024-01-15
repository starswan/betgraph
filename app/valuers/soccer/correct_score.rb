#
# $Id$
#
module Soccer
  # This and HalfTimeScore should have identical calculations
  # just with different parameters
  class CorrectScore < FullTimeValuer
    def initialize
      super
      @min = 0
      @max = 3
    end

    def value(homevalue, awayvalue, homescore, awayscore)
      winner(homevalue, awayvalue, homescore, awayscore) ? 1 : -1
    end

    # probability mass function
    def pmf(home, away)
      proc do |homeprob, awayprob|
        poisson_pmf(home).call(homeprob) * poisson_pmf(away).call(awayprob)
      end
    end

    # CorrectScore is a combination of 2 Poisson Variables which is the pmf above
    # for now just use the back prices rather than trying to work out if laying
    # everything apart from the runner produces a better answer
    def expected_value(_param1, pricelist)
      # The implementation of this is unclear.
      # Although it is possible in theory to value every runner price,
      # in practice some of the implied probabilities are so low that f'(x) -> 0
      # making convergence very difficult.
      pl = pricelist.map { |p|
        { home: p.fetch(:homevalue).to_i,
          away: p.fetch(:awayvalue).to_i,
          price: 1.0 / p.fetch(:backprice) }
      }.select { |pp| pp[:home] >= 0 && pp[:away] >= 0 }
      # values[0] === 0-0 (no goals)
      # values[1] === [1-0, 0-1]
      # values[2] === [2-0, 1-1, 0-2]
      # values[3] === [3-0, 2-1, 1-2, 0-3]
      # to go any higher we would need Correct Score 2 Home and Correct Score 2 Away
      # e.g. values[4] == [4-0, 3-1, 2-2, 1-3, 0-4] [5-0, 4-1, 3-2, 2-3, 1-4, 0-5].
      # 6 goals probably unobtainable as 4-2 and 2-4 rarely (never?) have runners
      # values = 0.upto(3).map do |goalcount|
      # convergence is a struggle with higher values of N
      values = 0.upto(0).map do |goalcount|
        hv = pl.select { |p| p[:home] + p[:away] == goalcount }.map { |p| p[:price] }.reduce(:+)
        hvfunc = CumulativePoisson.new(goalcount, hv)
        NewtonsMethod.solve(hv, hvfunc.method(:func), hvfunc.method(:funcdash)).value unless hv.nil?
      end
      OpenStruct.new(bid: nil, ask: nil)
    end

    # Calculate home and away lambda (average) goals for the moment based on Poisson distribution
    def lambda_h(goalcount, pricelist, xzero = 0)
      overround = pricelist.sum { |p| 1 / p.price }
      # Just solve for 0 and 1 - 2 and 3 often don't converge due to fdash being very small
      # ignore -ve p values as they represent 'any other home/away win or draw'
      solve_for(pricelist.select { |p| p[:home] == goalcount && p[:away] >= 0 }.sum { |p| overround / p.price }, goalcount, xzero)
    end

    def lambda_a(goalcount, pricelist, xzero = 2)
      overround = pricelist.sum { |p| 1 / p.price }
      # Just solve for 0 and 1 - 2 and 3 often don't converge due to fdash being very small
      # 0.upto(1).map do |goalcount|
      # ignore -ve p values as they represent 'any other home/away win or draw'
      solve_for(pricelist.select { |p| p[:away] == goalcount && p[:home] >= 0 }.sum { |p| overround / p.price }, goalcount, xzero)
      # end
    end

  private

    def solve_for(hv, goalcount, xzero)
      hvfunc = Poisson.new(goalcount, hv)
      NewtonsMethod.solve(xzero, hvfunc.method(:func), hvfunc.method(:funcdash)).value
    end

    def poisson_pmf(k)
      proc { |prob| prob * Math::E**-prob / k.factorial }
    end

    def winner(homevalue, awayvalue, homescore, awayscore)
      if homevalue >= @min && awayvalue >= @min
        (homevalue == homescore && awayvalue == awayscore)
      elsif homevalue == -1 && awayvalue == -1
        # -1, -1 means any other draw
        homescore > @max && homescore == awayscore
      elsif homevalue == 0 && awayvalue == -1
        # 0, -1 means any other away win
        awayscore > @max && awayscore > homescore
      elsif homevalue == -1 && awayvalue == 0
        # -1, 0 means any other home win
        homescore > @max && homescore > awayscore
      elsif homevalue == -3 && awayvalue == -3
        (homescore <= @max && awayscore <= @max)
      else
        ((homescore > @max) || (awayscore > @max))
      end
    end

    # can't have ever worked, as the methods for Poisson and func and funcdash
    #   def expectedForGoals(goals, prices)
    #     probability = 0
    #     prices.each do |runnertype, price|
    #       if runnertype.homevalue + runnertype.awayvalue == goals
    #         probability += 1 / price
    #       end
    #     end
    #     dist = Poisson.new(goals, probability)
    #     NewtonsMethod.solve(param1, dist.method(:prob), dist.method(:probdash))
    #   end
  end

  #   Just keeping the code from CorrectScore as it is being deleted.
  # class CorrectScore2
  #   def value homevalue, awayvalue, homescore, awayscore
  #     lessthan3goalseach = homescore < 3 and awayscore < 3
  #     moreThan7goals = homescore > 7 or awayscore > 7
  #     veryhighscoring = (homescore > 3 and awayscore > 2) or (homescore > 2 and awayscore > 3)
  #     winner = (homevalue >= 0 and awayvalue >= 0) ? (homevalue == homescore and awayvalue == awayscore) : lessthan3goalseach or moreThan7goals or veryhighscoring
  #     winner ? 1 : -1
  #   end
  #
  #   def probability homevalue, awayvalue, homescore, awayscore, phome, paway
  #     if homescore > homevalue or awayscore > awayvalue
  #       0
  #     else
  #       0
  #     end
  #   end
  #
  #   def expected param1, price
  #     []
  #   end
  # end
end
