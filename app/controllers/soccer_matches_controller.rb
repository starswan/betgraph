#
# $Id$
#
class SoccerMatchesController < ApplicationController
  ITEMS_PER_PAGE = 10
  MATCH_ACTIONS = [:show, :update, :destroy].freeze
  before_action :find_standard_params
  before_action :find_division_from_football_match, only: MATCH_ACTIONS
  before_action :find_division, except: MATCH_ACTIONS

  # GET /soccer_matches
  # GET /soccer_matches.xml
  def index
    @page = params[:page].to_i
    @football_matches = SoccerMatch.where(division: @division)
                                   .order("#{@order} #{@direction}")
                                   .page(@page).per(ITEMS_PER_PAGE)
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /soccer_matches/1
  # GET /soccer_matches/1.xml
  def show
    football_matches = SoccerMatch
                         .includes([{ teams: :team_names }, :division])
                         .order("#{@order} #{@direction}")

    if @offset > 0
      matches = football_matches.offset(@offset - 1).limit(3)
      @prev_football_match = matches[0]
      @next_football_match = matches[2] if matches.size > 2
    else
      @prev_football_match = football_matches.where("id < ?", params[:id]).last
      @next_football_match = football_matches.where("id > ?", params[:id]).first
      # matches = football_matches.limit(2)
      # @next_football_match = matches[1] if matches.size > 1
    end
    @soccer_match = SoccerMatch.includes(
      [
        :teams,
        :scorers,
        { division: { calendar: :sport } },
        :result,
        bet_markets: [
          { betfair_market_type: [:betfair_runner_types, :sport] },
          { market_runners: [{ betfair_runner_type: :betfair_market_type }, :market_prices] },
        ],
      ],
    ).find_by!(id: params[:id])
    # 0 for nil is exactly what we want here
    @matchtime = params[:matchtime].to_i

    respond_to do |format|
      format.html # show.html.erb
    end
  end

  def update
    respond_to do |format|
      live_count = BetMarket.live.count
      if @football_match.update(update_match_params)
        TickleLivePricesJob.perform_later if live_count.zero? && @football_match.live_priced
        flash[:notice] = "SoccerMatch was successfully updated."
        format.json { render json: @football_match }
      else
        format.json { render json: @football_match.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /soccer_matches/1
  # DELETE /soccer_matches/1.xml
  def destroy
    @football_match.destroy
    DestroyObjectJob.perform_later @football_match

    respond_to do |format|
      format.json { head :ok }
    end
  end

private

  def create_match_params
    params.require(:soccer_match)
          .permit(:actual_start_time, :half_time_duration, :kickofftime, :event, :name,
                  :endtime, :menu_path, :live_priced, :hometeam_id, :awayteam_id)
  end

  def update_match_params
    params.require(:soccer_match)
          .permit(:actual_start_time, :half_time_duration, :kickofftime, :event, :name,
                  :endtime, :live_priced)
  end

  def find_division_from_football_match
    @football_match = SoccerMatch.find(params[:id])
    @division = @football_match.division
  end

  def find_division
    @division = Division.find params[:division_id]
  end

  def find_standard_params
    @order = params[:order] || :kickofftime
    @direction = params[:direction] || :desc
    @threshold = (params[:threshold] || 11).to_i
    @offset = params[:offset] ? params[:offset].to_i : 0
    @limit = params.fetch(:limit, 20).to_i
  end
end
