# frozen_string_literal: true

#
# $Id$
#
# This works because CP(1) == P(1) + P(0) and DCP(1) == DP(1) + DP(0)
class CumulativePoisson
  def initialize(actual, offset)
    @subs = (0..actual).map { |m| Poisson.new(m, 0) }
    @offset = offset
  end

  def func(expected)
    @subs.map { |r| r.func(expected) }.reduce(:+) - @offset
  end

  def funcdash(expected)
    @subs.map { |r| r.funcdash(expected) }.reduce(:+)
  end
end
