#
# $Id$
#
require "rails_helper"

RSpec.describe Poisson do
  let(:poisson) { described_class.new(k, probability) }
  let(:result) { NewtonsMethod.solve(xzero, poisson.method(:func), poisson.method(:funcdash)).value.round(3) }

  context "0 arrivals" do
    let(:k) { 0 }
    let(:probability) { 0.082 }
    let(:xzero) { 1 }

    it "calculates average goals as about 2.5 for P(0) = 0.082" do
      expect(result).to eq(2.501)
    end
  end

  context "1 arrival" do
    let(:k) { 1 }
    let(:probability) { 0.205 }
    let(:xzero) { 2 }

    it "calculates average goals as about 2.5 for P(1) = 0.205" do
      expect(result).to eq(2.502)
    end
  end

  context "2 arrivals" do
    let(:k) { 2 }
    let(:probability) { 0.257 }
    let(:xzero) { 3 }

    it "calculates average goals as about 2.5 for P(2) = 0.257" do
      expect(result).to eq(2.490)
    end
  end

  context "3 arrivals" do
    let(:k) { 3 }
    let(:probability) { 0.213 }
    let(:xzero) { 2 }

    it "calculates average goals as about 2.5 for P(3) = 0.213" do
      expect(result).to eq(2.482)
    end
  end
end
