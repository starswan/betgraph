# frozen_string_literal: true

#
# $Id$
#
require "poisson"

class PoissonSum
  def initialize(kh, ka)
    @poissons = [Poisson.new(kh), Poisson.new(ka)]
  end

  def prob(expected)
    @poissons.map { |p| p.prob(expected) }.reduce(:+)
  end

  def probdash(expected)
    @poissons.map { |p| p.probdash(expected) }.reduce(:+)
  end
end
