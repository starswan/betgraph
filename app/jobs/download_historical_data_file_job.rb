#
# $Id$
#
class DownloadHistoricalDataFileJob < BetfairJob
  queue_priority PRIORITY_LOAD_FOOTBALL_DATA

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
      LoadHistoricalDataJob.perform_later event_id, JSON.parse(line, symbolize_names: true)
    end
  end
end
