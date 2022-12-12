# frozen_string_literal: true

FactoryBot.define do
  factory :login do
    name { "betfair" }
    username { "fred" }
    password { "password" }
  end

  class BetfairMenu
    attr_accessor :type, :name, :id, :exchangeId, :marketType, :numberOfWinners,
                  :marketStartTime, :children, :countryCode
  end

  factory :betfair_market, class: "BetfairMenu" do
    type { "MARKET" }
    name { "Moneyline" }
    id { "1.170406085" }
    exchangeId { "1" }
    marketType { "MATCH_ODDS" }
    marketStartTime { "2020-09-13T20:25:00.000Z" }
    numberOfWinners { 1 }
    children { [] }
  end

  factory :betfair_event, class: "BetfairMenu" do
    type { "EVENT" }
    name { "NFL Season 2020/21" }
    id { "29678534" }
    countryCode { "GB" }
    children { [] }
  end
end
