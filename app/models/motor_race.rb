# frozen_string_literal: true

#
# $Id$
#
# Don't really believe this - maybe this is so different
# that it should be stored in another table as there are often 24 competitors rather than 2

# Only problem is that betfair_event links back to match - so maybe the hometeam/awayteam thing
# so be split into teams pointing back to match, and having a venue field
class MotorRace < Match
  before_create :populate_venue

private

  def populate_venue
    # make the venue a fake team with the event name
    self.venue = sport.findTeam(name)
  end
end
