# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe Soccer do
  context "TeamTotalGoals" do
    subject { Soccer::TeamTotalGoals.new }

    it "has a value method with 5 parameters" do
      expect(subject.value_with_handicap(1, 0, 3, 0, 1)).to eq(0)
    end
  end

  context "TeamWinsAHalf" do
    subject { Soccer::TeamWinsAHalf.new }

    it "has a value method with 4 parameters" do
      expect(subject.value(1, 0, 3, 0)).to eq(0)
    end
  end

  context "TeamWinsBothHalves" do
    subject { Soccer::TeamWinsBothHalves.new }

    it "has a value method with 4 parameters" do
      expect(subject.value(1, 0, 3, 0)).to eq(0)
    end
  end

  context "BothTeamsToScore" do
    subject { Soccer::BothTeamsToScore.new }

    it "has a value method with 4 parameters" do
      expect(subject.value(1, 0, 3, 0)).to eq(-1)
    end
  end

  context "DoubleChance" do
    subject { Soccer::DoubleChance.new }

    it "has a value method with 4 parameters" do
      expect(subject.value(1, 0, 3, 0)).to eq(0)
    end
  end

  context "DrawNoBet" do
    subject { Soccer::DrawNoBet.new }

    it "has a value method with 4 parameters" do
      expect(subject.value(1, 0, 3, 0)).to eq(1)
    end
  end

  context "FirstHalfGoals" do
    subject { Soccer::FirstHalfGoals.new }

    it "has a value method with 4 parameters" do
      expect(subject.value(1, 0, 3, 0)).to eq(1)
    end
  end

  context "HalfTime" do
    subject { Soccer::HalfTime.new }

    it "has a value method with 4 parameters" do
      expect(subject.value(1, 0, 3, 0)).to eq(1)
    end

    it "has an expected method with 2 parameters" do
      expect(subject.expected_value(1, 0)).to eq(OpenStruct.new(bid: nil, ask: nil))
    end
  end

  context "HalfTimeScore" do
    subject { Soccer::HalfTimeScore.new }

    it "has a value method with 4 parameters" do
      expect(subject.value(1, 0, 3, 0)).to eq(-1)
    end
  end

  context "MatchOdds" do
    subject { Soccer::MatchOdds.new }

    it "has a value method with 4 parameters" do
      expect(subject.value(1, 0, 3, 0)).to eq(1)
    end
  end

  context "OddOrEven" do
    subject { Soccer::OddOrEven.new }

    it "has a value method with 4 parameters" do
      expect(subject.value(1, 0, 3, 0)).to eq(1)
    end
  end

  context "TeamToScoreInBothHalves" do
    subject { Soccer::TeamToScoreInBothHalves.new }

    it "has a value method with 4 parameters" do
      expect(subject.value(1, 0, 3, 0)).to eq(0)
    end
  end

  context "TeamWinsFromBehind" do
    subject { Soccer::TeamWinsFromBehind.new }

    it "has a value method with 4 parameters" do
      expect(subject.value(1, 0, 3, 0)).to eq(0)
    end
  end

  context "TeamWinsToNil" do
    subject { Soccer::TeamWinsToNil.new }

    it "has a value method with 4 parameters" do
      expect(subject.value(1, 0, 3, 0)).to eq(1)
    end
  end

  context "TotalGoals" do
    subject { Soccer::TotalGoals.new }

    it "has a value method with 5 parameters" do
      expect(subject.value(1, 0, 3, 0, 1)).to eq(1)
    end
  end

  context "TotalGoalsIndex" do
    subject { Soccer::TotalGoalsIndex.new }

    it "has a value method with 4 parameters" do
      expect(subject.value(1, 0, 3, 0)).to eq(0)
    end
  end
end
