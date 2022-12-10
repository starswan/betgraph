# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe DeleteInactiveMarketsJob, type: :job do
  it "creates some coverage stats" do
    described_class.perform_later
  end
end
