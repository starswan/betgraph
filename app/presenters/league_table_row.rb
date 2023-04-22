# frozen_string_literal: true

class LeagueTableRow
  delegate :name, to: :team, prefix: true

  attr_reader :team

  def initialize(team, matches)
    @team = team
    @matches = matches
  end

  def ordering
    -(1_000_000 * points + 1_000 * goal_difference + goals_scored)
  end

  def played
    @matches.count
  end

  def home_wins
    home.count { |m| m.homescore > m.awayscore }
  end

  def home_draws
    home.count { |m| m.homescore == m.awayscore }
  end

  def home_losses
    home.count { |m| m.homescore < m.awayscore }
  end

  def home_for
    home.map(&:homescore).sum
  end

  def home_against
    home.map(&:awayscore).sum
  end

  def away_wins
    away.count { |m| m.homescore < m.awayscore }
  end

  def away_draws
    away.count { |m| m.homescore == m.awayscore }
  end

  def away_losses
    away.count { |m| m.homescore > m.awayscore }
  end

  def away_for
    away.map(&:awayscore).sum
  end

  def away_against
    away.map(&:homescore).sum
  end

  def home_points
    @home_points ||= home
                    .map { |m| points_per_match(m.homescore, m.awayscore) }.sum
  end

  def away_points
    @away_points ||= away
                    .map { |m| points_per_match(m.awayscore, m.homescore) }.sum
  end

  def goal_difference
    home.map { |r| r.homescore - r.awayscore }.sum +
      away.map { |r| r.awayscore - r.homescore }.sum
  end

  def points
    home_points + away_points
  end

  def goals_scored
    home_for + away_for
  end

private

  def home
    @home ||= @matches.select { |m| m.hometeam == @team }.map(&:result)
  end

  def away
    @away ||= @matches.select { |m| m.awayteam == @team }.map(&:result)
  end

  def points_per_match(ours, others)
    if ours > others
      3
    elsif ours == others
      1
    else
      0
    end
  end
end
