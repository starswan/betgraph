#
# $Id$
#
class DownloadHistoricalDataFileJob < BetfairJob
  queue_priority PRIORITY_LOAD_FOOTBALL_DATA

  # It seems that Betfair sometimes give us a good (HTTP?) status but bad data from their API
  # so retry if that happens
  retry_on Bzip2::FFI::Error::MagicDataError

  def perform(filename)
    data = Enumerator.new do |yielder|
      Bzip2::FFI::Reader.open(StringIO.new(bc.download_file(filename))) do |reader|
        while (buffer = reader.read(8192))
          yielder << buffer
        end
      end
    end

    event_id = filename.split("/")[-2]
    StringIO.new(data.to_a.join).each_line(chomp: true) do |line|
      LoadHistoricalDataJob.new(logger).perform event_id, JSON.parse(line, symbolize_names: true)
    end
  end
end
