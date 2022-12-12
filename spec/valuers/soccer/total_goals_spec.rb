# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe Soccer::TotalGoals do
  it "has a value method with 5 parameters" do
    expect(described_class.new.value(1, 0, 3, 0, 1)).to eq(1)
  end
end
