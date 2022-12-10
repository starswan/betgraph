# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"
require "soccer/team_clean_sheet.rb"

RSpec.describe Soccer::TeamCleanSheet do
  subject { described_class.new }

  it "values home clean sheets" do
    # homevalue 1 means home clean sheet yes
    expect(subject.value(1, 0, 3, 0)).to eq(1)
    expect(subject.value(1, 0, 3, 1)).to eq(-1)
    # homevalue -1 means home clean sheet no
    expect(subject.value(-1, 0, 3, 0)).to eq(-1)
    expect(subject.value(-1, 0, 3, 1)).to eq(1)
  end

  it "values away clean sheets" do
    # awayvalue 1 means away clean sheet yes
    expect(subject.value(0, 1, 0, 3)).to eq(1)
    expect(subject.value(0, 1, 1, 3)).to eq(-1)
    # awayvalue -1 means away clean sheet no
    expect(subject.value(0, -1, 0, 3)).to eq(-1)
    expect(subject.value(0, -1, 1, 3)).to eq(1)
  end
end
