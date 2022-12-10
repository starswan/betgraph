# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe Multiply do
  let(:poisson) { described_class.new(Poisson.new(home, 0), Poisson.new(away, 0), 0.3) }

  context "when 0-0" do
    let(:home) { 0 }
    let(:away) { 0 }

    it "converges using Newtons Method" do
      expect(NewtonsMethod.solve(3, poisson.method(:func), poisson.method(:funcdash)).value).to eq(0.6019864001394172)
    end
  end
end
