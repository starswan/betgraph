# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe KeepAliveJob, :vcr, :betfair, type: :job do
  it "performs" do
    described_class.perform_later
  end
end
