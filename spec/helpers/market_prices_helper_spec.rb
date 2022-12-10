# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

# Specs in this file have access to a helper object that includes
# the MarketPricesHelper. For example:
#
# describe MarketPricesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe MarketPricesHelper, type: :helper do
  describe "#amount" do
    it "formats in pounds" do
      expect(helper.amount(950)).to eq "&pound;950.00"
    end
  end
end
