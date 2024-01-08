#
# $Id$
#
require "rails_helper"

RSpec.describe CumulativePoisson do
  let(:poisson) { described_class.new(arrivals, 0.3) }

  context "with 0 arrivals" do
    let(:arrivals) { 0 }

    it "converges using Newtons Method" do
      expect(NewtonsMethod.solve(3, poisson.method(:func), poisson.method(:funcdash)).value.round(3)).to eq(1.204)
    end
  end

  context "with 1 arrivals" do
    let(:arrivals) { 1 }

    it "converges using Newtons Method" do
      expect(NewtonsMethod.solve(3, poisson.method(:func), poisson.method(:funcdash)).value.round(4)).to eq(2.4392)
    end
  end
end
