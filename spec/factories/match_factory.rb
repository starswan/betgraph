# frozen_string_literal: true

#
# $Id$
#
FactoryBot.define do
  factory :match do
    name { "A v B" }
    kickofftime { Time.zone.now }

    factory :tennis_match do
      type { "TennisMatch" }
    end
  end

  factory :soccer_match do
    sequence(:name) { |n| "SoccerMatch #{n} A v B" }
    kickofftime { Time.zone.now }
    endtime { kickofftime + 110.minutes }
  end

  factory :result do
    homescore { 0 }
    awayscore { 0 }
  end
end
