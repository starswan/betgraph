# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe Soccer::HalfTime do
  let(:valuer) { described_class.new }

  it "has a value method with 4 parameters" do
    expect(valuer.value(1, 0, 3, 0)).to eq(1)
  end

  it "has an expected method with 2 parameters" do
    expect(valuer.expected_value(1, 0)).to eq(OpenStruct.new(bid: nil, ask: nil))
  end
end
