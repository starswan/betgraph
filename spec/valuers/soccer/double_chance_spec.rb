# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe Soccer::DoubleChance do
  it "has a value method with 4 parameters" do
    expect(described_class.new.value(1, 0, 3, 0)).to eq(0)
  end
end
