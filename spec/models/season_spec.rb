# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe Season do
  before do
    create(:season)
  end

  let(:season) { described_class.last }

  describe "#current?" do
    it "is not current for today" do
      expect(season.current?(Date.today)).to eq(false)
    end

    it "is current for the start plus a small bit" do
      expect(season.current?(season.startdate + 1.day)).to eq(true)
    end
  end
end
