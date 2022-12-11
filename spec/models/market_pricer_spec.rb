# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"
require "market_pricer"

RSpec.describe MarketPricer do
  Runner = Struct.new :bestPricesToBack, :bestPricesToLay
  MarketPriceGroup = Struct.new :runners

  let(:market_pricer) do
    runner = Runner.new [], []
    mpc = MarketPriceGroup.new [runner]
    described_class.new mpc
  end

  it "Back overround should work correctly" do
    expect(market_pricer.backOverround).to eq(1)
  end

  it "lay overround should work correctly" do
    expect(market_pricer.layOverround).to eq(0)
  end
end
