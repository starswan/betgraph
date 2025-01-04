# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe Soccer::DoubleChance do
  let(:homescore) { 3 }
  let(:awayscore) { 0 }

  it "is positive with home or away" do
    expect(described_class.new.value(0, 0, homescore, awayscore)).to eq(1)
  end

  it "is positive with home or draw" do
    expect(described_class.new.value(0, -1, homescore, awayscore)).to eq(1)
  end

  it "is negative with away or draw" do
    expect(described_class.new.value(-1, 0, homescore, awayscore)).to eq(-1)
  end
end
