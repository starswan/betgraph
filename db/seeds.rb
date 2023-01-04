# frozen_string_literal: true

#
# $Id$
#
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)
# root = MenuPath.create!(:active => false, :name => [], :depth => 1)
TeamTotalConfig.create! count: 7, threshold: 26, name: "Lowest Possible"
TeamTotalConfig.create! count: 11, threshold: 43, name: "Medium"
TeamTotalConfig.create! count: 14, threshold: 53, name: "Optimum"
TeamTotalConfig.create! count: 16, threshold: 66, name: "Highest Working"

Dir.new(Rails.root.join("app/valuers")).find_all { |dir| dir.first != "." && dir.last(3) != ".rb" }.each do |includedir|
  Dir.new(Rails.root.join("app/valuers/#{includedir}")).find_all { |i| i.first != "." }.each do |include|
    require(includedir + "/" + include)
  end
  # .each { |v| Valuer.create :name => v }
end

startyear = Time.zone.now.year + 50
startyear.downto(1990).each do |year|
  Season.create startdate: Date.new(year, 8, 1),
                name: "#{year}/#{year + 1}"
end
#
# SOCCER_NAME_CODE_MAP = { 'Belgian Div 1' => 'B1',
#                         'English Premiership' => 'E0'
#                       }
# MenuPath.create!(:active => false, :name => ['Soccer'], :parent_path => root, :depth => 0)
# soccer = Sport.find_by_name 'Soccer'
# SOCCER_NAME_CODE_MAP.each do |name, code|
#   div = soccer.divisions.create! :name => name, :active => true
#   div.create_football_division :football_data_code => code
# end
