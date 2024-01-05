#
# $Id$
#
FactoryBot.define do
  factory :team do
    association :sport
    after(:build) do |t|
      t.team_names = [build(:team_name)] if t.team_names.empty?
    end
  end

  factory :team_name do
    sequence(:name) { |n| "Team_#{n}" }
  end

  factory :team_division

  factory :team_total_config do
    count { 11 }
    threshold { 34 }
    name { "Whatever" }
  end
end
