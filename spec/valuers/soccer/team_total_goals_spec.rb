# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe Soccer::TeamTotalGoals do
  it "has a value method with 5 parameters" do
    expect(described_class.new.value_with_handicap(1, 0, 3, 0, 1)).to eq(0)
  end
end
