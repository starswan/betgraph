# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe RefreshSportListJob, type: :job do
  before do
    create(:login)
    stub_betfair_login
  end
  # let!(:soccer) { create(:sport, name: 'soccer', betfair_sports_id: 1,
  #                                    active: true, menu_paths: [build(:menu_path)])}

  it "performs" do
    # Should be done like this with mocks
    # expect(DummyBetfairLogin).to receive(:new).and_return()
    described_class.perform_later
  end
end
