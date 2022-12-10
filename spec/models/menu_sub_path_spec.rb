# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe MenuSubPath do
  let(:sport) { create(:sport, basket_rules: [build(:basket_rule, name: "Rule 1")]) }
  let(:english) { create(:menu_path, parent: sport.menu_paths.first) }
  let!(:championship) { create(:menu_path, parent: english) }

  before do
    create(:menu_path, parent: english)
  end

  it "new menu path creates sub-paths for each parent" do
    expect(english.menu_sub_paths.size).to eq(2)
    expect(championship.menu_sub_paths.size).to eq(0)

    expect {
      expect {
        newpath = sport.menu_paths.create! name: championship.name + ["Test"], parent: championship

        expect(newpath.menu_sub_paths.size).to eq(0)
      }.to change { english.menu_sub_paths.size }.by(1)
    }.to change(described_class, :count).by(3)
    # This assert used to fail as we've already loaded menu_paths(:three)
    # so rails doesn't know that it has changed
    # as a result of the create statement above
    championship.reload
    expect(championship.menu_sub_paths.size).to eq(1)
  end

  it "removing a menu path removes sub-paths" do
    expect {
      english.destroy
    }.to change(described_class, :count).by(-5)
  end
end
