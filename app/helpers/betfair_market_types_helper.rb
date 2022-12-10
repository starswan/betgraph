# frozen_string_literal: true

#
# $Id$
#
module BetfairMarketTypesHelper
  def delete_link(betfair_market_type)
    link_to "Delete", betfair_market_type, data: { confirm: "Are you sure you want to delete #{betfair_market_type.name}?" }, method: :delete, class: "btn btn-sm btn-outline-danger"
  end
end
