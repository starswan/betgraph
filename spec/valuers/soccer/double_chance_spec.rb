# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe Soccer::DoubleChance do
  let(:homescore) { 3 }

  context "with home win" do
    let(:awayscore) { 0 }

    it "is positive with home or away" do
      expect(described_class.new.value(0, 0, homescore, awayscore)).to eq(1)
    end

    it "is positive with home or draw" do
      expect(described_class.new.value(0, -1, homescore, awayscore)).to eq(1)
    end

    it "is negative with away or draw" do
      expect(described_class.new.value(-1, 0, homescore, awayscore)).to eq(-1)
    end
  end

  context "with away win" do
    let(:awayscore) { 4 }

    it "is positive with home or away" do
      expect(described_class.new.value(0, 0, homescore, awayscore)).to eq(1)
    end

    it "is negative with home or draw" do
      expect(described_class.new.value(0, -1, homescore, awayscore)).to eq(-1)
    end

    it "is positive with away or draw" do
      expect(described_class.new.value(-1, 0, homescore, awayscore)).to eq(1)
    end
  end

  context "with draw" do
    let(:awayscore) { 3 }

    it "is negative with home or away" do
      expect(described_class.new.value(0, 0, homescore, awayscore)).to eq(-1)
    end

    it "is positive with home or draw" do
      expect(described_class.new.value(0, -1, homescore, awayscore)).to eq(1)
    end

    it "is positive with away or draw" do
      expect(described_class.new.value(-1, 0, homescore, awayscore)).to eq(1)
    end
  end
end
