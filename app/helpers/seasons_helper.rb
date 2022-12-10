# frozen_string_literal: true

#
# $Id$
#
module SeasonsHelper
  def left_title(football_season)
    football_season.current?(Date.today) ? "Results" : "Jul-Dec"
  end

  def right_title(football_season)
    football_season.current?(Date.today) ? "Fixtures" : "Jan-Jun"
  end

  class MatchDisplay
    attr_reader :division, :nilnilscore
    delegate :homescore, :awayscore, to: :@result
    delegate :kickofftime, :hometeam, :awayteam, to: :@match

    def initialize(match, nil_nil_score)
      @match = match
      @result = match.result
      @nilnilscore = nil_nil_score
      @division = match.division.football_division.football_data_code
    end

    def colour
      @colour = if @result.homescore + @result.awayscore == 0
                  "green"
                else
                  (@result.homescore == 1) && (@result.awayscore == 0) ? "blue" : "red"
                end
    end
  end

  def match_display(match, nilnilscore)
    MatchDisplay.new match, nilnilscore
  end

  class FixtureDisplay
    attr_reader :homescore, :awayscore, :colour, :division, :nilnilscore

    delegate :kickofftime, :hometeam, :awayteam, to: :@match

    def initialize(match, colour)
      @match = match
      @homescore = "vs"
      @awayscore = ""
      @nilnilscore = colour
      @division = match.division.football_division.football_data_code
      @colour = if (colour > 0) && (colour < 7)
                  %w[orange yellow green brown blue pink][colour - 1]
                elsif colour <= 0
                  "red"
                else
                  "black"
                end
    end
  end

  def fixture_display(match, display_value)
    FixtureDisplay.new(match, display_value)
  end
end
