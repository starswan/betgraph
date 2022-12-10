# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe FootballDivision do
  before do
    create(:division)
  end

  let(:division) { create(:division) }

  it "Can create a new division" do
    expect {
      described_class.create! football_data_code: "SP1",
                              division: division
    }.to change(described_class, :count).by(1)
  end
  # test "can make new matches by magic" do
  #   assert_difference('FootballMatch.count', 2) do
  #      football_divisions(:one).football_matches.create! :betfair_soccer_match => betfair_soccer_matches(:three),
  #                                                        :footie_fixture => footie_fixtures(:five)
  #      football_divisions(:one).auto_football_matches
  #   end
  # end
end
