# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe TradesHelper, type: :helper do
  it "does valid bet sizes" do
    expect(helper.valid_bet_sizes).to eq([[2, 2], [3, 3]])
  end
end
