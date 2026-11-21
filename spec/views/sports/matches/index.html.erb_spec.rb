require "rails_helper"

RSpec.describe "sports/matches/index" do
  before do
    assign :active_sports, []
    assign :sport, build_stubbed(:sport)
    assign :matches, build_stubbed_list(:soccer_match, 1)
    assign :model, Sports::MatchesController::Model.new(direction: :asc, offset: 0, limit: 0, priced_only: false, order: "")
    render
  end

  it "renders the use my location button" do
    expect(rendered).to have_content("Match")
  end
end
