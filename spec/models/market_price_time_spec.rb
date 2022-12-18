# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe MarketPriceTime do
  it "requires time" do
    expect(build(:market_price_time, time: nil)).not_to be_valid
    expect(build(:market_price_time, time: Time.zone.now)).to be_valid
  end
end
