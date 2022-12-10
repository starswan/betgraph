# frozen_string_literal: true

#
# $Id$
#
class Result < ApplicationRecord
  belongs_to :match
  validates :homescore, :awayscore, presence: true

  after_create do |result|
    ttc = TeamTotalConfig.order("count desc").first
    unless ttc.nil?
      result.add_new_total(ttc, result.match.hometeam, result.homescore, result.awayscore)
      result.add_new_total(ttc, result.match.awayteam, result.awayscore, result.homescore)
    end
  end

  before_destroy do |result|
    TeamTotal.where(match: result.match).delete_all
  end

  def add_new_total(ttc, team, goals_for, goals_against)
    result = self
    last_mt = MatchTeam.joins(:match)
                       .order("matches.kickofftime")
                       .where("matches.kickofftime < ? and team_id = ?", result.match.kickofftime, team.id)
                       .last
    if last_mt
      last_match = last_mt.match
      last_tts = TeamTotal.joins("inner join matches as m on team_totals.match_id = m.id")
                          .where("match_id = ? and count < ? and team_id = ?", last_match.id, ttc.count, team.id)
                          .order("m.kickofftime desc")
                          .limit(ttc.count - 1)
      last_tts.each do |last_tt|
        TeamTotal.create! count: last_tt.count + 1,
                          team: team,
                          match: result.match,
                          total_goals: last_tt.total_goals + goals_for + goals_against,
                          goals_for: last_tt.goals_for + goals_for,
                          goals_against: last_tt.goals_against + goals_against
      end
    end
    TeamTotal.create! count: 1,
                      team: team,
                      match: result.match,
                      total_goals: goals_for + goals_against,
                      goals_for: goals_for,
                      goals_against: goals_against
  end
end
