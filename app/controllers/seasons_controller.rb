#
# $Id$
#
class SeasonsController < ApplicationController
  before_action :find_sport, except: %i[new create edit update destroy]
  before_action :find_calendar, only: %i[new create edit update destroy]

  # Our threshold parameter is in the URL, so hopefully this should now work
  caches_page :show

  # GET /football_seasons
  # GET /football_seasons.xml
  def index
    @seasons = Season.order(startdate: :desc).where("startdate < ?", Time.zone.today + 1.year)

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  SeasonDisplay = Struct.new :id, :name, keyword_init: true
  # GET /football_seasons/1
  # GET /football_seasons/1.xml
  def show
    @season_list = Season.order(startdate: :desc).where("startdate < ?", Time.zone.today).map do |s|
      SeasonDisplay.new id: s.id, name: "#{s.name} - #{s.calendar.name}"
    end

    @season = Season.find(params[:season_id] || params[:id])
    @football_matches = SoccerMatch.where(season: @season)
                          .ordered_by_date
                          .includes(:division, :result, { teams: :team_names })
    @enddate = Season.where("startdate > ?", @season.startdate)
                     .order("startdate").first.startdate - 1.day

    @team_total_configs = TeamTotalConfig.all.each_with_object({}) { |ttc, hash| hash[ttc.count] = ttc.threshold }
    # default to second option (usually 11) rather than 7 which doesn't generally perform well.
    @threshold = params[:threshold] || @team_total_configs.keys.sort.second
    threshold = @threshold.to_i
    @threshValue = @team_total_configs[threshold]

    # This controller should just return interesting results and fixtures, and then let the view
    # work out how to display that information based on the data.
    @results = []
    @fixtures = []

    @leftarray = []
    @rightarray = []
    current_season = @season.current? Time.zone.today
    @nilnil = @onenil = @nilone = 0

    team_totals = TeamTotal.includes(:team).by_count(threshold).where(match: @football_matches).index_by { |tt| [tt.team_id, tt.match_id] }
    @result_summaries = Hash.new(0)
    last_home_game = {}
    last_away_game = {}
    @football_matches.each do |match|
      result = match.result
      hometeam = match.hometeam
      awayteam = match.awayteam
      logger.debug "match #{index} #{match.id} #{match.kickofftime} #{hometeam.name} #{awayteam.name}"

      # The idea here was to speed up the controller - but it seems to give different answers????
      # next if (team_totals[[hometeam.id, match.id]]&.total_goals || 0) + (team_totals[[awayteam.id, match.id]]&.total_goals || 0) > @threshValue

      # lasthomegame = matches[0..index-1].reverse.detect { |m| m.teams.map(&:id).include?(hometeam.id) }
      homegame = last_home_game[hometeam.id]
      # lastawaygame = matches[0..index-1].reverse.detect { |m| m.teams.map(&:id).include?(awayteam.id) }
      awaygame = last_away_game[awayteam.id]

      last_home_game[hometeam.id] = match
      last_away_game[awayteam.id] = match

      next unless homegame && awaygame

      homegoals_tt = team_totals[[hometeam.id, homegame.id]]
      awaygoals_tt = team_totals[[awayteam.id, awaygame.id]]

      if homegoals_tt && awaygoals_tt

        if current_season
          if result
            if homegoals_tt.total_goals + awaygoals_tt.total_goals <= @threshValue
              display_value = @threshValue - homegoals_tt.total_goals - awaygoals_tt.total_goals
              @leftarray << view_context.match_display(match, display_value)
              @result_summaries[[result.homescore, result.awayscore]] += 1

              @results << [match, display_value]
            end
          else
            if match.kickofftime > Time.zone.now
              display_value = homegoals_tt.total_goals + awaygoals_tt.total_goals - @threshValue
              if display_value < 8
                @rightarray << view_context.fixture_display(match, display_value)
                @fixtures << [match, display_value]
              end
            end
          end
        else
          if homegoals_tt.total_goals + awaygoals_tt.total_goals <= @threshValue
            display_value = @threshValue - homegoals_tt.total_goals - awaygoals_tt.total_goals
            if match.kickofftime.month <= 6
              @rightarray << view_context.match_display(match, display_value)
            else
              @leftarray << view_context.match_display(match, display_value)
            end
            @results << [match, display_value]
            @result_summaries[[result.homescore, result.awayscore]] += 1
          end
        end
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
      format.html do
        # if current_season
        #   render layout: "current_football_season"
        # else
        #   render
        # end
      end
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

  # GET /football_seasons/1/edit
  def edit
    @season = Season.find(params[:id])
  end

  # POST /football_seasons
  # POST /football_seasons.xml
  def create
    @season = @calendar.seasons.new(season_params)

    respond_to do |format|
      if @season.save
        format.html { redirect_to calendar_seasons_path(@calendar), notice: "FootballSeason was successfully created." }
        format.xml  { render xml: @season, status: :created, location: @season }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @season.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /football_seasons/1
  # PUT /football_seasons/1.xml
  def update
    @season = Season.find(params[:id])

    respond_to do |format|
      if @season.update(season_params)
        format.html { redirect_to(calendar_seasons_path(@calendar), notice: "FootballSeason was successfully updated.") }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @season.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /football_seasons/1
  # DELETE /football_seasons/1.xml
  def destroy
    @season = Season.find(params[:id])
    @season.destroy!

    respond_to do |format|
      format.html { redirect_to sport_seasons_path(@calendar.sport) }
    end
  end

private

  def find_sport
    @soccer = Sport.find params[:sport_id]
  end

  def find_calendar
    @calendar = Calendar.find params[:calendar_id]
  end

  def season_params
    params.require(:season).permit(:name, :online, :startdate)
  end
end
