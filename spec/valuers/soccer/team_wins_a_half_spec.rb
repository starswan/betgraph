# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe Soccer::TeamWinsAHalf do
  it "is a dummy class" do
    valuer = described_class.new
    expect(valuer.value(0, 0, 0, 0)).to eq(0)
  end
end
