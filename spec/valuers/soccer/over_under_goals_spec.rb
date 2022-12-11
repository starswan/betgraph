# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"
require "soccer/over_under_goals"

RSpec.describe Soccer::OverUnderGoals do
  let(:data_points) do
    [
      { m: 0.5, b: [1.06, 1.07], l: [15.5, 16.5], x: 2.74083949495, y: 2.86219885673 },
      { m: 1.5, b: [1.29, 1.3], l: [4.3, 4.5], x: 2.79133257600680, y: 2.837280407 },
      { m: 2.5, b: [1.87, 1.89], l: [2.12, 2.14], x: 2.790597082, y: 2.81771898640 },
      { m: 3.5, b: [3.1, 3.2], l: [1.46, 1.47], x: 2.831456218294841, y: 2.8651203329556076 },
      { m: 4.5, b: [6.4, 6.6], l: [1.18, 1.19], x: 2.8014021376284717, y: 2.8250754036453083 },
      { m: 5.5, b: [14, 15], l: [1.07, 1.08], x: 2.8035524378, y: 2.8704952230 },
      { m: 6.5, b: [36, 38], l: [1.02, 1.03], x: 2.8297241572186884, y: 2.8791117580828 },
    ]
  end

  it "expected value calculated correctly" do
    valuer = described_class.new
    data_points.each do |datum|
      first = { backprice: datum[:b][0], layprice: datum[:b][1], homevalue: datum[:m] }
      last = { backprice: datum[:l][0], layprice: datum[:l][1], homevalue: -datum[:m] }
      expected = valuer.expected_value(datum[:m], [first, last])
      # puts "#{datum[:m]} #{expected}"
      assert_in_delta datum[:x], expected.bid, 0.001
      assert_in_delta datum[:y], expected.ask, 0.001
      expected2 = valuer.expected_value(datum[:m], [last, first])
      # puts "#{datum[:m]} #{expected}"
      assert_in_delta datum[:x], expected2.bid, 0.001
      assert_in_delta datum[:y], expected2.ask, 0.001
    end
  end
end
