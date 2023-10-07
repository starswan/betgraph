#
# $Id$
#
class LoadHistoricalFileJob < ApplicationJob
  queue_as :default

  # File not found can't be retried
  discard_on SystemCallError

  # IOStreams doesn't support iterators or each_with_index (boo!)
  # but it was the only library I could find that could read lines on-the-fly in ruby
  class Bzip2Iterator
    include Enumerable

    def initialize(filename)
      @filename = filename
    end

    def each(&block)
      IOStreams.path(@filename).each(&block)
    end
  end

  def perform(filename)
    Bzip2Iterator.new(filename).each do |raw_line|
      line = JSON.parse(raw_line, symbolize_names: true)

      LoadHistoricalDataJob.perform_later line
    end
  end
end
