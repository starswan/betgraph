#
# $Id$
#
module NewtonsMethod
  Solution = Struct.new(:value, :loops)
  EPSILON = 0.000001

  class << self
    class NewtonsMethodNotConverging < StandardError; end

    def solve_for(func, guess = 0)
      solve(guess, func.method(:func), func.method(:funcdash))
    end

    def solve(guess, func, funcdash, epsilon = EPSILON)
      loops = 0
      f = func.call(guess)
      while f.abs > epsilon
        fdash = funcdash.call(guess)
        guess -= f / fdash
        newvalue = func.call(guess)
        # Need to wait a certain number of iterations before deciding that things are not working
        raise NewtonsMethodNotConverging, [loops, newvalue.round(5)] if newvalue.abs >= f.abs && loops > 4

        loops += 1
        Rails.logger.debug format("Newton Raphson iteration [#{loops}] x=%2.5f %2.5f f(x)=%2.5f", guess, f, newvalue)
        f = newvalue
      end
      Solution.new guess, loops
    end
  end
end
