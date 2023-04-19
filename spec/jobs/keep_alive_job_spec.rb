# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe KeepAliveJob, :vcr, :betfair, type: :job do
  before do
    create(:login)
  end

  it "performs" do
    described_class.perform_later
  end
end
