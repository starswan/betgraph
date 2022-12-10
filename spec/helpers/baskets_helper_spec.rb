# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe BasketsHelper, type: :helper do
  let(:match) { build(:match, baskets: [build(:basket)]) }
  let(:baskets) { match.baskets }

  it "maps" do
    expect(helper.basket_data(baskets)).to eq [{ id: nil, label: "Thing", prices: {} }]
  end
end
