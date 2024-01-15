#
# $Id$
#
require "rails_helper"

RSpec.describe Soccer::CorrectScore do
  describe "#value" do
    let(:valuer) { described_class.new }

    it "values correct scores" do
      expect(valuer.value(0, 0, 0, 0)).to eq(1)
      expect(valuer.value(0, 1, 0, 0)).to eq(-1)
      expect(valuer.value(4, 0, 4, 0)).to eq(1)
    end

    it "values any other result" do
      expect(valuer.value(-4, -4, 0, 0)).to eq(-1)
      expect(valuer.value(-4, -4, 4, 0)).to eq(1)
      expect(valuer.value(-4, -4, 4, 1)).to eq(1)
      expect(valuer.value(-4, -4, 4, 2)).to eq(1)
    end

    it "values any other score for correct score 2" do
      expect(valuer.value(-3, -3, 0, 4)).to eq(-1)
      expect(valuer.value(-3, -3, 0, 5)).to eq(-1)
      expect(valuer.value(-3, -3, 0, 6)).to eq(-1)
      expect(valuer.value(-3, -3, 0, 7)).to eq(-1)
      expect(valuer.value(-3, -3, 0, 0)).to eq(1)
      expect(valuer.value(-3, -3, 0, 1)).to eq(1)
    end

    it "values any other draw" do
      expect(valuer.value(-1, -1, 0, 0)).to eq(-1)
      expect(valuer.value(-1, -1, 4, 0)).to eq(-1)
      expect(valuer.value(-1, -1, 4, 1)).to eq(-1)
      expect(valuer.value(-1, -1, 4, 2)).to eq(-1)
      expect(valuer.value(-1, -1, 4, 4)).to eq(1)
      expect(valuer.value(-1, -1, 5, 5)).to eq(1)
    end

    it "values any other away" do
      expect(valuer.value(0, -1, 0, 0)).to eq(-1)
      expect(valuer.value(0, -1, 4, 0)).to eq(-1)
      expect(valuer.value(0, -1, 4, 1)).to eq(-1)
      expect(valuer.value(0, -1, 4, 2)).to eq(-1)
      expect(valuer.value(0, -1, 3, 4)).to eq(1)
      expect(valuer.value(0, -1, 3, 5)).to eq(1)
    end

    it "values any other home" do
      expect(valuer.value(-1, 0, 0, 0)).to eq(-1)
      expect(valuer.value(-1, 0, 3, 0)).to eq(-1)
      expect(valuer.value(-1, 0, 3, 1)).to eq(-1)
      expect(valuer.value(-1, 0, 3, 2)).to eq(-1)
      expect(valuer.value(-1, 0, 4, 4)).to eq(-1)
      expect(valuer.value(-1, 0, 4, 3)).to eq(1)
      expect(valuer.value(-1, 0, 5, 3)).to eq(1)
      expect(valuer.value(-1, 0, 5, 1)).to eq(1)
    end
  end

  context "when solving goal counts from odds values" do
    let(:valuer) { described_class.new }

    let(:real_prices) do
      [
        { home: 0, away: 0, b: [{ 17.0 => 715.92 }, { 16.5 => 763.38 }, { 16.0 => 1243.88 }], l: [{ 17.5 => 203.82 }, { 18.0 => 551.21 }, { 18.5 => 2064.13 }] },
        { home: 0, away: 1, b: [{ 7.8 => 112.01 }, { 7.6 => 281.28 }, { 7.4 => 1093.23 }], l: [{ 8.0 => 20.47 }, { 8.2 => 28.93 }, { 8.4 => 519.83 }] },
        { home: 0, away: 2, b: [{ 7.0 => 472.31 }, { 6.8 => 412.65 }, { 6.6 => 304.82 }], l: [{ 7.4 => 11.38 }, { 7.6 => 414.47 }, { 7.8 => 264.81 }] },
        { home: 0, away: 3, b: [{ 10.0 => 469.33 }, { 9.8 => 91.79 }, { 9.6 => 163.72 }], l: [{ 11.0 => 173.13 }, { 11.5 => 112.4 }, { 12.0 => 379.33 }] },
        { home: 1, away: 0, b: [{ 27.0 => 26.12 }, { 26.0 => 252.33 }, { 25.0 => 81.5 }], l: [{ 29.0 => 21.06 }, { 30.0 => 94.96 }, { 32.0 => 32.71 }] },
        { home: 1, away: 1, b: [{ 11.0 => 37.23 }, { 10.5 => 174.12 }, { 10.0 => 570.35 }], l: [{ 11.5 => 314.85 }, { 12.0 => 405.4 }, { 12.5 => 133.85 }] },
        { home: 1, away: 2, b: [{ 10.5 => 170.0 }, { 10.0 => 1233.13 }, { 9.8 => 376.18 }], l: [{ 11.0 => 491.67 }, { 11.5 => 157.53 }, { 12.0 => 62.58 }] },
        { home: 1, away: 3, b: [{ 14.0 => 203.73 }, { 13.5 => 202.13 }, { 13.0 => 284.64 }], l: [{ 14.5 => 61.27 }, { 15.0 => 328.72 }, { 15.5 => 208.21 }] },
        { home: 2, away: 0, b: [{ 65.0 => 36.28 }, { 60.0 => 77.29 }, { 55.0 => 50.66 }], l: [{ 80.0 => 12.65 }, { 85.0 => 58.97 }, { 90.0 => 11.66 }] },
        { home: 2, away: 1, b: [{ 32.0 => 17.23 }, { 30.0 => 126.36 }, { 29.0 => 144.26 }], l: [{ 36.0 => 76.88 }, { 44.0 => 106.37 }, { 1000.0 => 16.53 }] },
        { home: 2, away: 2, b: [{ 29.0 => 18.16 }, { 28.0 => 59.26 }, { 27.0 => 404.74 }], l: [{ 32.0 => 214.83 }, { 34.0 => 27.41 }, { 90.0 => 10.42 }] },
        { home: 2, away: 3, b: [{ 40.0 => 15.06 }, { 38.0 => 221.2 }, { 36.0 => 134.13 }], l: [{ 42.0 => 45.01 }, { 44.0 => 36.1 }, { 50.0 => 20.94 }] },
        { home: 3, away: 0, b: [{ 280.0 => 13.64 }, { 270.0 => 35.26 }, { 200.0 => 16.02 }], l: [{ 340.0 => 11.21 }] },
        { home: 3, away: 1, b: [{ 130.0 => 16.41 }, { 120.0 => 23.46 }, { 110.0 => 107.26 }], l: [{ 170.0 => 23.75 }, { 1000.0 => 9.22 }] },
        { home: 3, away: 2, b: [{ 120.0 => 16.98 }, { 110.0 => 91.44 }, { 100.0 => 112.42 }], l: [{ 1000.0 => 14.08 }] },
        { home: 3, away: 3, b: [{ 160.0 => 31.34 }, { 150.0 => 79.9 }, { 140.0 => 19.45 }], l: [{ 190.0 => 21.48 }, { 1000.0 => 5.4 }] },
        { home: -1, away: 0, b: [{ 190.0 => 34.85 }, { 180.0 => 53.45 }, { 150.0 => 14.98 }], l: [{ 1000.0 => 6.8 }] },
        { home: 0, away: -1, b: [{ 6.4 => 661.89 }, { 6.2 => 74.6 }, { 6.0 => 804.74 }], l: [{ 6.8 => 76.41 }, { 7.0 => 245.9 }, { 7.2 => 104.27 }] },
        { home: -1, away: -1, b: [{ 1000.0 => 22.33 }, { 120.0 => 11.39 }, { 20.0 => 18.96 }], l: [] },
      ]
    end

    let(:zero_prices) { [{ home: 0, away: 0, price: 17.0 }, { home: 0, away: 1, price: 7.8 }, { home: 0, away: 2, price: 7.0 }, { home: 0, away: 3, price: 10.0 }] }
    let(:one_prices) { [{ home: 1, away: 0, price: 27.0 }, { home: 1, away: 1, price: 11.0 }, { home: 1, away: 2, price: 10.5 }, { home: 1, away: 3, price: 14.0 }] }
    let(:two_prices) { [{ home: 2, away: 0, price: 65.0 }, { home: 2, away: 1, price: 32.0 }, { home: 2, away: 2, price: 29.0 }, { home: 2, away: 3, price: 40.0 }] }
    let(:three_prices) { [{ home: 3, away: 0, price: 280.0 }, { home: 3, away: 1, price: 130.0 }, { home: 3, away: 2, price: 120.0 }, { home: 3, away: 3, price: 160.0 }] }
    let(:other_prices) { [{ home: -1, away: 0, price: 190.0 }, { home: 0, away: -1, price: 6.4 }, { home: -1, away: -1, price: 1000.0 }] }

    let(:prices) { zero_prices + one_prices + two_prices + three_prices + other_prices }
    let(:bmt_prices) { prices.map { |p| BetfairMarketType::ExpectedPrice.new(home: p.fetch(:home), away: p.fetch(:away), price: p.fetch(:price)) } }

    describe "#lambda_h" do
      let(:home) { [valuer.lambda_h(0, bmt_prices), valuer.lambda_h(1, bmt_prices)] }

      it "returns lambda h" do
        expect(home.map { |r| r.round(3) }).to eq([0.825, 0.49])
      end
    end

    describe "#lambda_a" do
      let(:away) { [valuer.lambda_a(0, bmt_prices), valuer.lambda_a(1, bmt_prices)] }

      it "returns lambda a" do
        expect(away.map { |r| r.round(3) }).to eq([2.146, 2.057])
      end
    end
  end

  describe "#pmf" do
    context "0-0" do
      let(:valuer) { described_class.new.pmf(0, 0) }

      it "has a pmf" do
        expect(valuer.call(2, 1)).to eq(0.0995741367357279)
      end
    end

    context "1-1" do
      let(:valuer) { described_class.new.pmf(1, 1) }

      it "has a pmf" do
        expect(valuer.call(1, 2)).to eq(0.0995741367357279)
      end
    end

    context "2-1" do
      let(:valuer) { described_class.new.pmf(2, 1) }

      it "has a pmf" do
        expect(valuer.call(1, 2)).to eq(0.04978706836786395)
      end
    end
  end
end
