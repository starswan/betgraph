# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"
require "soccer/asian_handicap.rb"

RSpec.describe Soccer::AsianHandicap do
  let(:valuer) { described_class.new }

  it "minus half goal valued" do
    expect(valuer.value_with_handicap(1, 0, 0, 0, -0.5)).to eq(-1)
    expect(valuer.value_with_handicap(0, 1, 0, 0, -0.5)).to eq(-1)
    expect(valuer.value_with_handicap(1, 0, 1, 0, -0.5)).to eq(1)
    expect(valuer.value_with_handicap(0, 1, 0, 1, -0.5)).to eq(1)
  end

  it "half goal advantage valued" do
    expect(valuer.value_with_handicap(1, 0, 0, 0, 0.5)).to eq(1)
    expect(valuer.value_with_handicap(0, 1, 0, 0, 0.5)).to eq(1)
    expect(valuer.value_with_handicap(1, 0, 0, 1, 0.5)).to eq(-1)
    expect(valuer.value_with_handicap(0, 1, 1, 0, 0.5)).to eq(-1)
  end

  it "minus quarter goal advantage valued" do
    expect(valuer.value_with_handicap(1, 0, 0, 0, -0.25)).to eq(-0.5)
    expect(valuer.value_with_handicap(0, 1, 0, 0, -0.25)).to eq(-0.5)
    expect(valuer.value_with_handicap(1, 0, 1, 0, -0.25)).to eq(1)
    expect(valuer.value_with_handicap(0, 1, 0, 1, -0.25)).to eq(1)
  end

  it "quarter goal advantage valued" do
    expect(valuer.value_with_handicap(1, 0, 0, 0, 0.25)).to eq(0.5)
    expect(valuer.value_with_handicap(0, 1, 0, 0, 0.25)).to eq(0.5)
    expect(valuer.value_with_handicap(1, 0, 0, 1, 0.25)).to eq(-1)
    expect(valuer.value_with_handicap(0, 1, 1, 0, 0.25)).to eq(-1)
  end

  it "minus 3-quarter goal advantage valued" do
    expect(valuer.value_with_handicap(1, 0, 0, 0, -0.75)).to eq(-1)
    expect(valuer.value_with_handicap(0, 1, 0, 0, -0.75)).to eq(-1)
    expect(valuer.value_with_handicap(1, 0, 1, 0, -0.75)).to eq(0.5)
    expect(valuer.value_with_handicap(0, 1, 0, 1, -0.75)).to eq(0.5)
  end

  it "3-quarter goal advantage valued" do
    expect(valuer.value_with_handicap(1, 0, 0, 0, 0.75)).to eq(1)
    expect(valuer.value_with_handicap(0, 1, 0, 0, 0.75)).to eq(1)
    expect(valuer.value_with_handicap(1, 0, 0, 1, 0.75)).to eq(-0.5)
    expect(valuer.value_with_handicap(0, 1, 1, 0, 0.75)).to eq(-0.5)
  end

  it "expected_value" do
    expect(valuer.expected_value(1, 2)).to eq(OpenStruct.new(bid: nil, ask: nil))
  end
end
