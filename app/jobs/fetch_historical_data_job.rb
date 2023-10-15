#
# $Id$
#
class FetchHistoricalDataJob < BetfairJob
  queue_priority PRIORITY_LOAD_FOOTBALL_DATA

  def perform(target_date, country)
    x = bc.get_my_data

    last_x = x.last
    Date.parse(last_x.fetch("forDate"))

    mt = BetfairMarketType.where(active: true)
    market_types = BetMarket.where(betfair_market_type: mt).pluck(:markettype).uniq

    opts = {
      sport: last_x.fetch("sport"),
      plan: last_x.fetch("plan"),
      # fromDay: 1,
      # fromMonth: last_time.month,
      # fromYear: last_time.year,
      # toDay: last_time.at_end_of_month.day,
      # toMonth: last_time.month,
      # toYear: last_time.year,
      fromDay: target_date.day,
      fromMonth: target_date.month,
      fromYear: target_date.year,
      toDay: target_date.day,
      toMonth: target_date.month,
      toYear: target_date.year,
      eventId: nil,
      eventName: nil,
      marketTypesCollection: market_types,
      countriesCollection: [country],
      fileTypeCollection: %w[M],
    }
    _collection_opts = bc.get_collection_options opts
    files = bc.download_list_of_files(opts).reject do |f|
      name = f.split("/").last
      market_id = name.split(".")[0..-2].join(".")
      BetMarket.by_betfair_market_id(market_id).exists?
    end

    files.each do |filename|
      DownloadHistoricalDataFileJob.perform_later filename
    end
  end
end
