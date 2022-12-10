# frozen_string_literal: true

#
# $Id$
#
FactoryBot.define do
  factory :match do
    name { "A v B" }
    kickofftime { Time.now }

    factory :tennis_match do
      type { "TennisMatch" }
    end
  end

  factory :soccer_match do
    name { "A v B" }
    kickofftime { Time.now }
    endtime { Time.now + 110.minutes }
  end

  factory :result do
    homescore { 0 }
    awayscore { 0 }
  end
end
