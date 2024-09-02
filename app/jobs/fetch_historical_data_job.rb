#
# $Id$
#
class FetchHistoricalDataJob < BetfairJob
  queue_priority PRIORITY_LOAD_FOOTBALL_DATA

  def perform(target_date, country)
    my_data_hash = bc.get_my_data.map(&:symbolize_keys)

    this_data_block = my_data_hash.detect do |b|
      date = Date.parse(b.fetch(:forDate)).to_date
      target_date.between? date, date.end_of_month
    end

    return if this_data_block.nil?

    market_types = BetMarket.where(betfair_market_type: BetfairMarketType.active).pluck(:markettype).uniq.sort

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
    all_files = bc.download_list_of_files(opts).reject do |f|
      name = f.split("/").last
      market_id = name.split(".")[0..-2].join(".")
      BetMarket.by_betfair_market_id(market_id).exists?
    end

    # If all the event ids are known for a date, we can download just those ids
    # wonder if we could use the 'eventName' filter above?
    download_event_ids = all_files.map { |f| f.split("/")[-2] }.uniq
    all_event_ids = Match.played_on(target_date).map(&:betfair_event_id).map(&:to_s)

    download_files = if all_event_ids.all? { |x| download_event_ids.include?(x) }
                       all_files.select do |f|
                         all_event_ids.any? { |e| f.include?(e) }
                       end
                     else
                       all_files
                     end

    download_files.each do |filename|
      DownloadHistoricalDataFileJob.perform_later filename
    end
  end
end
