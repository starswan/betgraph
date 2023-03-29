# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProcessMarketPriceJob, type: :job do
  Snapshot = Struct.new :marketId, :status, :runners, keyword_init: true
  Runner = Struct.new :status, :selectionId, :handicap, :ex, keyword_init: true
  Ex = Struct.new :availableToBack, :availableToLay, keyword_init: true
  ExPrice = Struct.new :price, :size, keyword_init: true

  let(:season) { create(:season) }
  let(:division) { create(:division, calendar: season.calendar) }
  let(:sport) { season.calendar.sport }
  let(:now) { Time.zone.now }
  let(:market_price_time) { create(:market_price_time) }
  let(:snapshot) do
    {
      marketId: "1.211281516",
      status: "OPEN",
      runners: [
        {
          "selectionId" => 56_301,
          "handicap" => 0.0,
          "status" => "ACTIVE",
          :ex => {
            "availableToBack" => [{ "price" => 2.52, "size" => 98.68 },
                                  { "price" => 2.5, "size" => 58.41 },
                                  { "price" => 2.44, "size" => 53.26 }],
            "availableToLay" => [{ "price" => 2.86, "size" => 27.49 },
                                 { "price" => 3.0, "size" => 44.25 },
                                 { "price" => 3.15, "size" => 22.81 }],
          },
        },
        {
          "selectionId" => 69_746,
          "handicap" => 0.0,
          "status" => "ACTIVE",
          :ex => { "availableToBack" => [{ "price" => 6.8, "size" => 10.57 },
                                         { "price" => 6.6, "size" => 15.04 },
                                         { "price" => 5.5, "size" => 14.29 }],
                   "availableToLay" => [{ "price" => 8.4, "size" => 13.78 },
                                        { "price" => 9.4, "size" => 13.36 },
                                        { "price" => 15.0, "size" => 11.03 }] },
        },
        {
          "selectionId" => 58_805,
          "handicap" => 0.0,
          "status" => "ACTIVE",
          :ex => {
            "availableToBack" => [{ "price" => 1.88, "size" => 41.82 },
                                  { "price" => 1.87, "size" => 88.5 },
                                  { "price" => 1.82, "size" => 20.4 }],
            "availableToLay" => [{ "price" => 2.12, "size" => 131.04 },
                                 { "price" => 2.2, "size" => 32.66 },
                                 { "price" => 2.22, "size" => 44.73 }],
          },
        },
      ].map do |r|
                 Runner.new(r.merge(ex: Ex.new(r.fetch(:ex).transform_values { |p_list| p_list.map { |p| ExPrice.new(p) } })))
               end,
    }
  end

  before do
    create(:soccer_match,
           division: division, kickofftime: now, name: "A v B",
           bet_markets:
             build_list(:bet_market, 1,
                        :open,
                        exchange_id: 1,
                        marketid: 211_281_516,
                        market_runners: [
                          build(:market_runner, selectionId: 56_301),
                          build(:market_runner, selectionId: 69_746),
                          build(:market_runner, selectionId: 58_805),
                        ]))
  end

  it "processes data correctly" do
    expect {
      described_class.perform_now BetMarket.first, Snapshot.new(snapshot).freeze, market_price_time
    }.to change(MarketPrice, :count).by(3)
  end
end
