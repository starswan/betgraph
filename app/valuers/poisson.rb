#
# $Id$
#
class Poisson
  # offset here is purely so that we can solve f(x) = 3 rather than f(x) = 0
  # k is number of actual arrivals
  def initialize(kvalue, offset)
    # Rails.logger.debug("Poisson #{kvalue} #{offset}")
    @k = kvalue
    @offset = offset
  end

  # P(k) = (lambda^k)(E^ -lambda) / k!
  # want to solve this for P(k) == y for unknown lambda
  # derivative is DP(k) wrt lambda which is y = f(x) * g(x) === f'(x) * g(x) + g'(x) * f(x)
  # A(x) === x^k, B(x) === E^-x
  # for k == 0, DA(x) = 1, DB(x) = -E^-x
  # for k > 0, DA(x) == k * x^(k-1) DB(x) == -E^-x

  def func(expected)
    f(expected) * g(expected) - @offset
  end

  def funcdash(expected)
    if @k == 0
      gdash(expected)
    else
      fdash(expected) * g(expected) + f(expected) * gdash(expected)
    end
  end

private

  def f(expected)
    # Rails.logger.debug("Poisson f #{expected}")
    expected**@k
  end

  def fdash(expected)
    @k * (expected**(@k - 1))
  end

  def g(expected)
    Math::E**-expected / @k.factorial
  end

  def gdash(expected)
    -(Math::E**-expected) / @k.factorial
  end
end
