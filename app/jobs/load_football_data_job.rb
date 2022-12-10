# frozen_string_literal: true

#
# $Id$
#
require "open-uri"
require "csv"
require "zip"

class LoadFootballDataJob < ApplicationJob
  queue_priority PRIORITY_LOAD_FOOTBALL_DATA

  def perform(today_as_string)
    today = Date.parse(today_as_string)
    season = Season.where("startdate <= ?", today).order(:startdate).last
    year = season.startdate.year % 100
    # year = if today.month < 7
    #          today.year % 100
    #        else
    #          today.year % 100 + 1
    #        end
    nextyear = year == 99 ? 0 : year + 1
    yearstr = format("%02d", year)
    nextyearstr = format("%02d", nextyear)
    url = "https://www.football-data.co.uk/mmz4281/#{yearstr}#{nextyearstr}/data.zip"
    logger.debug "Opening URL #{url}"
    zipfile = URI.open(url)

    # weirdly sometimes open_uri returns a File object,and sometimes a StringIO...
    Zip::InputStream.open(zipfile) do |zip_stream|
      while entry = zip_stream.get_next_entry
        div = entry.name.split(".").first
        football_division = FootballDivision.includes(:division).find_by(football_data_code: div)
        if football_division && football_division.division.active
          parse_input_stream(entry.get_input_stream.read, football_division.division)
        else
          logger.info { "Skipping division #{div}" }
        end
      end
    end
  end

  # Reus Deportiu matches all reported as 1-0 losses after club expelled
  # from Spanish soccer for 3 years for not paying players wages - last valid match was 12-Jan-2019
  REUS_DEPORTIU = "Reus Deportiu"

  # This could now be a parallel job if required as it just takes an array and a division
  def parse_input_stream(data, division)
    # soccer = Sport.find_by_name 'soccer'
    # map with parse and group_by { |row| row[0] } so we can parse each division as we go.
    # the memory overhead is probably very low (a few Kb) - 20 ish divisions with 10 x 40 results = 8000 rows of CSV.
    # result is a map with division -> [array of rows]
    csv = CSV.new(data, row_sep: "\r\n", headers: true)

    csv.map(&:to_h).reject { |r| r["Div"].nil? }.map { |row|
      datebits = row["Date"].split "/"
      year = datebits[2].to_i
      year += 1900 if year < 1000
      year += 100 if year < 1950
      row.merge("Date" => Date.civil(year, datebits[1].to_i, datebits[0].to_i))
    }.reject { |item| (item["HomeTeam"] == REUS_DEPORTIU || item["AwayTeam"] == REUS_DEPORTIU) && item["Date"] > Date.new(2019, 1, 12) }
      .each do |r|
      logger.debug { "Processing row #{r}" }
      # some old files have 'HT' and 'AT' rather than HomeTeam and AwayTeam
      if r.key? "HT"
        r["HomeTeam"] = r["HT"]
      end
      if r.key? "AT"
        r["AwayTeam"] = r["AT"]
      end
      r["HomeTeam"] = convert_team r["HomeTeam"]
      r["AwayTeam"] = convert_team r["AwayTeam"]

      # it seems that the hash can get a 'nil' key in it sometimes
      FootballDataJob.perform_later(r.except(nil), division)
    end
  end

  def convert_team(teamname)
    # Need to convert funny smart quote into normal one for King's Lynn
    teamname.gsub(0x92.chr, "'")
  end
end