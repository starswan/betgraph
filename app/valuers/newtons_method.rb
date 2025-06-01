#
# $Id$
#
module NewtonsMethod
  # Solution = Struct.new(:value, :loops)
  Solution = Data.define(:value, :loops)
  # EPSILON = 0.000001
  EPSILON = 0.00001

  class << self
    class NewtonsMethodNotConverging < StandardError; end

    # def solve_for(func, guess = 0)
    #   solve(guess, func.method(:func), func.method(:funcdash))
    # end
    # Iteration = Struct.new :f, :x, keyword_init: true
    Iteration = Data.define(:f, :x)

    # if we don't convert to float, arbitrary precision arithmetic can take hold
    # which results in very very long compute times
    def solve(xzero, func, funcdash, epsilon = EPSILON)
      loops = 0
      iter0 = iterate(xzero.to_f, func, funcdash)
      iter_n = iterate(iter0.x, func, funcdash)
      # iter_n = iterate(xzero.to_f, func, funcdash)
      while iter_n.f.abs > epsilon
        old_iter = iter_n
        iter_n = iterate(iter_n.x, func, funcdash)
        # converges quatratically so this test should always work satisfactorily - hard to cover with tests
        # :nocov:
        # raise NewtonsMethodNotConverging, [loops, xnplus1.round(5)] if iter_n.f.abs > old_iter.f.abs
        # raise NewtonsMethodNotConverging, [loops, iter_n.x.round(5)] if iter_n.f.abs > old_iter.f.abs && loops > 7
        return Solution.new(value: nil, loops: loops) if iter_n.f.abs > old_iter.f.abs
        # :nocov:

        loops += 1
        # Rails.logger.debug format("Newton Raphson iteration [#{loops}] x0=%2.6f x1=%2.6f f(x)=%2.6f", old_iter.x, iter_n.x, iter_n.f)
      end
      Solution.new(value: iter_n.x, loops: loops)
    end

  private

    def iterate(xzero, func, funcdash)
      f0 = func.call(xzero)
      fdash0 = funcdash.call(xzero)
      x1 = xzero - f0 / fdash0
      Iteration.new(f: f0, x: x1)
    end
  end
end
