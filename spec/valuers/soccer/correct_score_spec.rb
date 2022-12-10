# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe Soccer::CorrectScore do
  describe "#value" do
    it "values correct scores" do
      expect(subject.value(0, 0, 0, 0)).to eq(1)
      expect(subject.value(0, 1, 0, 0)).to eq(-1)
      expect(subject.value(4, 0, 4, 0)).to eq(1)
    end

    it "values any other result" do
      expect(subject.value(-4, -4, 0, 0)).to eq(-1)
      expect(subject.value(-4, -4, 4, 0)).to eq(1)
      expect(subject.value(-4, -4, 4, 1)).to eq(1)
      expect(subject.value(-4, -4, 4, 2)).to eq(1)
    end

    it "values any other score for correct score 2" do
      expect(subject.value(-3, -3, 0, 4)).to eq(-1)
      expect(subject.value(-3, -3, 0, 5)).to eq(-1)
      expect(subject.value(-3, -3, 0, 6)).to eq(-1)
      expect(subject.value(-3, -3, 0, 7)).to eq(-1)
      expect(subject.value(-3, -3, 0, 0)).to eq(1)
      expect(subject.value(-3, -3, 0, 1)).to eq(1)
    end

    it "values any other draw" do
      expect(subject.value(-1, -1, 0, 0)).to eq(-1)
      expect(subject.value(-1, -1, 4, 0)).to eq(-1)
      expect(subject.value(-1, -1, 4, 1)).to eq(-1)
      expect(subject.value(-1, -1, 4, 2)).to eq(-1)
      expect(subject.value(-1, -1, 4, 4)).to eq(1)
      expect(subject.value(-1, -1, 5, 5)).to eq(1)
    end

    it "values any other away" do
      expect(subject.value(0, -1, 0, 0)).to eq(-1)
      expect(subject.value(0, -1, 4, 0)).to eq(-1)
      expect(subject.value(0, -1, 4, 1)).to eq(-1)
      expect(subject.value(0, -1, 4, 2)).to eq(-1)
      expect(subject.value(0, -1, 3, 4)).to eq(1)
      expect(subject.value(0, -1, 3, 5)).to eq(1)
    end

    it "values any other home" do
      expect(subject.value(-1, 0, 0, 0)).to eq(-1)
      expect(subject.value(-1, 0, 3, 0)).to eq(-1)
      expect(subject.value(-1, 0, 3, 1)).to eq(-1)
      expect(subject.value(-1, 0, 3, 2)).to eq(-1)
      expect(subject.value(-1, 0, 4, 4)).to eq(-1)
      expect(subject.value(-1, 0, 4, 3)).to eq(1)
      expect(subject.value(-1, 0, 5, 3)).to eq(1)
      expect(subject.value(-1, 0, 5, 1)).to eq(1)
    end
  end

  describe "#pmf" do
    context "0-0" do
      subject { described_class.new.pmf(0, 0) }

      it "has a pmf" do
        expect(subject.call(2, 1)).to eq(0.0995741367357279)
      end
    end

    context "1-1" do
      subject { described_class.new.pmf(1, 1) }

      it "has a pmf" do
        expect(subject.call(1, 2)).to eq(0.0995741367357279)
      end
    end

    context "2-1" do
      subject { described_class.new.pmf(2, 1) }

      it "has a pmf" do
        expect(subject.call(1, 2)).to eq(0.04978706836786395)
      end
    end
  end
end
