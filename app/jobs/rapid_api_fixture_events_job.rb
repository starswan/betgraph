class RapidApiFixtureEventsJob < RapidApiJob
  queue_priority PRIORITY_LOAD_FOOTBALL_DATA

  def perform(soccer_match, rapidapi_fixture_id, teams)
    event_list = faraday.get("/v3/fixtures/events", fixture: rapidapi_fixture_id).body.fetch(:response).select { |f| f.fetch(:type) == "Goal" }

    event_list.each do |goal|
      goaltime = goal.dig(:time, :elapsed)
      soccer_match.scorers.create! goaltime: goaltime <= 45 ? (60 * goaltime) : 60 * (goaltime + 15),
                                   owngoal: goal.fetch(:detail) == "OwnGoal",
                                   penalty: goal.fetch(:detail) == "Penalty",
                                   name: goal.dig(:player, :name),
                                   team: goal.dig(:team, :name) == teams.dig(:home, :name) ? soccer_match.hometeam : soccer_match.awayteam
    end
  end
end
