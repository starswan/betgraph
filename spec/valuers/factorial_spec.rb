# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe "factorial" do
  it "works for some values" do
    { 0 => 1, 1 => 1, 2 => 2, 3 => 6, 4 => 24, 5 => 120, 6 => 720 }.each do |k, v|
      expect(k.factorial).to eq(v)
    end
  end
end
