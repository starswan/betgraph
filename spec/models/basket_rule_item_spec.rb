# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe BasketRuleItem do
  let(:rule) { create(:basket_rule) }
  let(:runner_type) { create(:betfair_runner_type) }
  let!(:item) { create(:basket_rule_item, basket_rule: rule, betfair_runner_type: runner_type) }

  it "basket rule items exist" do
    expect(item.weighting).to eq(1)
  end

  it "items can be created" do
    expect {
      rule.basket_rule_items.create! weighting: 1, betfair_runner_type: runner_type
    }.to change(described_class, :count).by(1)
  end

  it "items can be destroyed" do
    expect {
      item.destroy
    }.to change(described_class, :count).by(-1)
  end
end
