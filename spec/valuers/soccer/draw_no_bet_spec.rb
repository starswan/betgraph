# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe Soccer::DrawNoBet do
  describe "#value" do
    it "values home win" do
      expect(subject.value(1.0, 0.0, 3, 2)).to eq(1)
      expect(subject.value(0.0, 1.0, 3, 2)).to eq(-1)
    end

    it "values away win" do
      expect(subject.value(1.0, 0.0, 0, 1)).to eq(-1)
      expect(subject.value(0.0, 1.0, 0, 1)).to eq(1)
    end

    it "values draw" do
      expect(subject.value(1.0, 0.0, 0, 0)).to eq(0)
      expect(subject.value(0.0, 1.0, 0, 0)).to eq(0)
    end
  end
end
