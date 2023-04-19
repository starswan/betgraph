# frozen_string_literal: true

#
# $Id$
#
class RefreshSportListJob < BetfairJob
  queue_priority PRIORITY_REFRESH_SPORT_LIST

  def perform
    bc.getActiveEventTypes.each do |event_type|
      sport = Sport.find_or_create_by!(name: event_type.fetch(:name), betfair_sports_id: event_type.fetch(:id))
      if sport.active
        competitions = bc.get_competitions_for_event(event_type)

        competitions.reject { |c| sport.competitions.pluck(:name).include? c.fetch(:name) }.each do |comp|
          sport.competitions.create! name: comp.fetch(:name),
                                     region: comp.fetch(:competitionRegion),
                                     betfair_id: comp.fetch(:id)
        end
        MakeMatchesJob.perform_later sport
      end
    end
  end
end
