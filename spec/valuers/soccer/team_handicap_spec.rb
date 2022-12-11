# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"
require "soccer/team_handicap"

RSpec.describe Soccer::TeamHandicap do
  subject { described_class.new }

  it "values -1 draw +1 when 2-0 as home win" do
    # homevalue 1 means home clean sheet yes
    expect(subject.value(-1, 0, 2, 0)).to eq(1)
    expect(subject.value(0, 1, 2, 0)).to eq(-1)
    expect(subject.value(-1, -1, 2, 0)).to eq(-1)
  end
end
