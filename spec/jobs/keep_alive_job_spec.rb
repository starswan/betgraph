# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe KeepAliveJob, :betfair, type: :job do
  let!(:login) { create(:login) }

  before do
    stub_betfair_login
  end

  it "performs" do
    stub_request(:post, "https://identitysso-cert.betfair.com/api/keepAlive")
      .with(
        headers: {
          "Accept" => "application/json",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "User-Agent" => "Ruby",
          "X-Application" => "3zshEzQv183tM6sh",
          "X-Authentication" => "token",
        },
      )
      .to_return(status: 200, body: {}.to_json, headers: {})

    described_class.perform_later
  end
end
