# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe MasterCryptoProvider do
  it "exercises some execution paths so that coverage is happy" do
    x = "some stuff"
    y = described_class.encrypt(x)
    expect(y).not_to eq(x)
    expect(described_class.decrypt(y)).to eq(x)
  end
end
