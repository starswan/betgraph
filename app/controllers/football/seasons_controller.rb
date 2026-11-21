#
# $Id$
module Football
  class SeasonsController < ApplicationController
    # GET /football/seasons
    def index
      sport = Sport.find_by! name: "Soccer"
      calendars = sport.calendars
      @seasons = Season.order(startdate: :desc).where(calendar: calendars).where("startdate < ?", Time.zone.today + 1.year)
    end

    SeasonDisplay = Struct.new :id, :name, keyword_init: true
    # GET /football_seasons/1
    def show
      sport = Sport.find_by! name: "Soccer"
      calendars = sport.calendars
      @season_list = Season.where(calendar: calendars).order(startdate: :desc).where("startdate < ?", Time.zone.today).map do |s|
        SeasonDisplay.new id: s.id, name: "#{s.name} - #{s.calendar.name}"
      end

      @season = Season.find(params[:season_id] || params[:id])
      football_matches = SoccerMatch.where(season: @season).joins(:division).merge(Division.active)
                            .ordered_by_date
                            .includes(:division, :result, { teams: :team_names })
      @enddate = Season.where("startdate > ?", @season.startdate)
                       .order("startdate").first.startdate - 1.day

      @team_total_configs = TeamTotalConfig.all.each_with_object({}) { |ttc, hash| hash[ttc.count] = ttc.threshold }
      # default to second option (usually 11) rather than 7 which doesn't generally perform well.
      @threshold = params[:threshold] || @team_total_configs.keys.sort.second
      threshold = @threshold.to_i
      thresh_value = @team_total_configs[threshold]

      # This controller should just return interesting results and fixtures, and then let the view
      # work out how to display that information based on the data.
      @results = []
      @fixtures = []

      @leftarray = []
      @rightarray = []
      current_season = @season.current? Time.zone.today
      @nilnil = @onenil = @nilone = 0

      @result_summaries = Hash.new(0)
      team_to_score_list = football_matches.reduce({}) do |h, fm|
        h.tap do |hash|
          hash[fm.hometeam.id] ||= []
          hash[fm.hometeam.id] << fm
          hash[fm.awayteam.id] ||= []
          hash[fm.awayteam.id] << fm
        end
      end
      # simplecov:disable
      team_id_to_match_id_to_totals = team_to_score_list.transform_values do |match_list|
        #  key match_id, value sum of scores in previous N matches
        match_list.each_cons(threshold + 1)
                  .filter_map { |l|
                    tail = l[0..-2]
                    [l.last.id, tail.sum(0) { |r| r.result.homescore + r.result.awayscore }] if tail.all? { |match| match.result.present? }
                  }.to_h
      end
      # simplecov:enable
      interesting_matches = football_matches.select do |match|
        home_total = team_id_to_match_id_to_totals.fetch(match.hometeam.id)[match.id]
        away_total = team_id_to_match_id_to_totals.fetch(match.awayteam.id)[match.id]

        home_total.present? && away_total.present? && home_total + away_total <= thresh_value
      end
      interesting_matches.each do |match|
        home_total = team_id_to_match_id_to_totals.fetch(match.hometeam.id).fetch(match.id)
        away_total = team_id_to_match_id_to_totals.fetch(match.awayteam.id).fetch(match.id)
        total_goals = home_total + away_total
        result = match.result
        if current_season
          if result
            display_value = thresh_value - total_goals
            @leftarray << view_context.match_display(match, display_value)
            @result_summaries[[result.homescore, result.awayscore]] += 1

            @results << [match, display_value]
          elsif match.kickofftime > Time.zone.now
            display_value = total_goals - thresh_value
            if display_value < 8
              @rightarray << view_context.fixture_display(match, display_value)
              @fixtures << [match, display_value]
            end
          end
        else
          display_value = thresh_value - total_goals
          if match.kickofftime.month <= 6
            @rightarray << view_context.match_display(match, display_value)
          else
            @leftarray << view_context.match_display(match, display_value)
          end
          @results << [match, display_value]
          @result_summaries[[result.homescore, result.awayscore]] += 1
        end
      end
      @nilnil = @result_summaries[[0, 0]]
      @onenil = @result_summaries[[1, 0]]
      @nilone = @result_summaries[[0, 1]]
      @total = if current_season
                 @leftarray.size
               else
                 @leftarray.size + @rightarray.size
               end

      respond_to do |format|
        format.html
      end
    end

    # GET /football_seasons/new
    # GET /football_seasons/new.xml
    def new
      @season = Season.new

      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render xml: @season }
      end
    end
  end
end
