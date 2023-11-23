#
# $Id$
#
class DownloadHistoricalDataFileJob < BetfairJob
  queue_priority PRIORITY_LOAD_FOOTBALL_DATA

  def perform(filename)
    data_stream = StringIO.new(bc.download_file(filename))

    data = ""
    Bzip2::FFI::Reader.open(data_stream) do |reader|
      while (buffer = reader.read(8192))
        # process uncompressed bytes in buffer
        data += buffer
      end
    end

    event_id = filename.split("/")[-2]
    StringIO.new(data).each_line(chomp: true) do |line|
      LoadHistoricalDataJob.perform_later event_id, JSON.parse(line, symbolize_names: true)
    end
  end
end
