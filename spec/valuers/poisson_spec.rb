# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe Poisson do
  let(:poisson) { described_class.new(arrivals, 0.3) }

  context "0 arrivals" do
    let(:arrivals) { 0 }

    it "converges using Newtons Method" do
      expect(NewtonsMethod.solve(3, poisson.method(:func), poisson.method(:funcdash)).value).to eq(1.203972801529768)
    end
  end

  context "1 arrivals" do
    let(:arrivals) { 1 }

    it "converges using Newtons Method" do
      expect(NewtonsMethod.solve(3, poisson.method(:func), poisson.method(:funcdash)).value).to eq(1.7813370261423394)
    end
  end
end
