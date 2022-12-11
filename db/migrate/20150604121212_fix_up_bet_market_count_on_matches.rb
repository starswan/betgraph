# frozen_string_literal: true

#
# $Id$
#
class FixUpBetMarketCountOnMatches < ActiveRecord::Migration[4.2]
  BATCH_SIZE = 10000
  def up
    index, count = 0, Match.count
    Match.find_in_batches(batch_size: BATCH_SIZE) do |group|
      say_with_time "Match #{index}/#{count}" do
        Match.transaction do
          group.each do |match|
            if match.bet_markets_count != match.bet_markets.count
              logger.debug "Adjusting #{match.id} #{match.kickofftime} #{match.name} #{match.bet_markets_count} #{match.bet_markets.count}"
              Match.reset_counters match, :bet_markets
            end
            # match.destroy if match.bet_markets_count == 0
          end
        end
        index += group.size
      end
    end
  end

  def down; end
end
