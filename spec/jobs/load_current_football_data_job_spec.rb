# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe LoadCurrentFootballDataJob, type: :job do
  before do
    create(:season, startdate: Time.zone.today)
  end

  it "performs" do
    fixtures1819 = File.read(Rails.root.join("spec/fixtures/1819.zip"))
    year = Season.first.startdate.year % 100
    req_year = "#{year}#{year + 1}"

    stub_request(:get, "https://www.football-data.co.uk/mmz4281/#{req_year}/data.zip")
      .to_return(body: fixtures1819, headers: {})

    described_class.perform_later
  end
end
