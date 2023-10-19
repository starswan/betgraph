#
# $Id$
#
class FetchHistoricalDataJob < BetfairJob
  queue_priority PRIORITY_LOAD_FOOTBALL_DATA

  def perform(target_date, country)
    x = bc.get_my_data.map(&:symbolize_keys)

    this_data_block = x.detect do |b|
      date = Date.parse(b.fetch(:forDate)).to_date
      target_date.between? date, date.end_of_month
    end

    mt = BetfairMarketType.where(active: true)
    market_types = BetMarket.order(:markettype).where(betfair_market_type: mt).pluck(:markettype).uniq

    opts = {
      sport: this_data_block.fetch(:sport),
      plan: this_data_block.fetch(:plan),
      fromDay: target_date.day,
      fromMonth: target_date.month,
      fromYear: target_date.year,
      toDay: target_date.day,
      toMonth: target_date.month,
      toYear: target_date.year,
      eventId: nil,
      eventName: nil,
      # marketTypesCollection: market_types + ['Unspecified'],
      marketTypesCollection: market_types,
      # countriesCollection: [country] + ['Unspecified'],
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
