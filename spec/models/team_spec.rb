# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe Team do
  context "without division" do
    let!(:team) { create(:team) }

    it "can destroy a team" do
      expect {
        team.destroy
      }.to change(described_class, :count).by(-1)
    end

    it "has a sport scope" do
      expect(described_class.for_sport(team.sport).count).not_to eq(0)
    end
  end

  context "with division" do
    let(:team) { create(:team) }
    let(:division) { create(:division) }
    let!(:td) { create(:team_division, team: team, division: division, season_id: 1) }

    it "can be destroyed" do
      expect {
        expect {
          team.destroy
        }.to change(TeamDivision, :count).by(-1)
      }.not_to change(Division, :count)
    end
  end
end
