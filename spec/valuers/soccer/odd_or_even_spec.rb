# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe Soccer::OddOrEven do
  describe "#value" do
    it "values odd" do
      expect(subject.value(1.0, 0.0, 3, 2)).to eq(1)
      expect(subject.value(0.0, 0.0, 3, 2)).to eq(-1)
    end

    it "values even" do
      expect(subject.value(1.0, 0.0, 1, 1)).to eq(-1)
      expect(subject.value(0.0, 0.0, 1, 1)).to eq(1)
    end
  end
end
