#
# $Id$
#
require "rails_helper"

RSpec.describe Multiply do
  let(:poisson) { described_class.new(Poisson.new(home, 0.6), Poisson.new(away, 0.3)) }

  context "when 0-0" do
    let(:home) { 0 }
    let(:away) { 0 }

    it "converges using Newtons Method" do
      expect(NewtonsMethod.solve(3, poisson.method(:func), poisson.method(:funcdash)).value.round(3)).to eq(0.511)
    end
  end
end
