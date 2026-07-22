#
# $Id$
#
require "rails_helper"

RSpec.describe Soccer::HalfTimeScore do
  describe "#value" do
    it "values correct scores" do
      expect(subject.value(-3, -3, 3, 0)).to eq(1)
      expect(subject.value(0, 0, 0, 0)).to eq(1)
      expect(subject.value(0, 0, 0, 1)).to eq(-1)
      expect(subject.value(1, 0, 1, 0)).to eq(1)
    end
  end
end
