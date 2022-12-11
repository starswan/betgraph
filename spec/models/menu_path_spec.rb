# frozen_string_literal: true

#
# $Id$
#
require "rails_helper"

RSpec.describe MenuPath do
  let(:sport) { create(:sport, basket_rules: [build(:basket_rule, name: "Rule 1")]) }
  let(:menu_path) { sport.menu_paths.first }
  let(:english) { create(:menu_path, parent: sport.menu_paths.first) }

  before do
    create(:menu_path, parent: english)
    create(:menu_path, parent: english)
  end

  it "menu path methods work" do
    expect(english).not_to be_active
    expect(menu_path.lastname).to eq sport.name
    expect(described_class.findByName([sport.name])).to eq(menu_path)
  end

  it "creating an active menu path creates a division" do
    expect {
      mp = menu_path.sport.menu_paths.create! active: true, parent: menu_path, name: menu_path.name + %w[whatever]
      expect(mp.division.name).to eq "whatever"
      expect(mp.division).to be_active
    }.to change(Division, :count).by(1)
  end

  it "destroying a menu path destroys its sub paths" do
    expect {
      menu_path.destroy
    }.to change(MenuSubPath, :count).by(-5)
  end
end
