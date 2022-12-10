# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"
require "market_pricer"

RSpec.describe MarketPricer do
  Runner = Struct.new :bestPricesToBack, :bestPricesToLay
  MarketPriceGroup = Struct.new :runners

  before do
    runner = Runner.new [], []
    mpc = MarketPriceGroup.new [runner]
    @market_pricer = described_class.new mpc
  end

  it "Back overround should work correctly" do
    assert_equal 1, @market_pricer.backOverround
  end

  it "lay overround should work correctly" do
    assert_equal 0, @market_pricer.layOverround
  end

private

  def assert_equal(a, b)
    expect(a).to eq(b)
  end
end
