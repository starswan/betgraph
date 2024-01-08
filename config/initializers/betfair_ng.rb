module Betfair
  module HistoricalData
    HISTORIC_DATA_API_PREFIX = "https://historicdata.betfair.com/api"
    def keep_alive
      get url: "https://identitysso-cert.betfair.com/api/keepAlive"
    end

    def get_my_data
      get url: "#{HISTORIC_DATA_API_PREFIX}/GetMyData", headers: { "ssoid" => persistent_headers.fetch("X-Authentication") }
    end

    def get_collection_options body
      post url: "#{HISTORIC_DATA_API_PREFIX}/GetCollectionOptions",
           headers: { "ssoid" => persistent_headers.fetch("X-Authentication") },
      body: body.to_json
    end

    def download_list_of_files body
      post url: "#{HISTORIC_DATA_API_PREFIX}/DownloadListOfFiles",
           headers: { "ssoid" => persistent_headers.fetch("X-Authentication") },
           body: body.to_json
    end

    def download_file filename
      get url: "#{HISTORIC_DATA_API_PREFIX}/DownloadFile",
           headers: { "ssoid" => persistent_headers.fetch("X-Authentication") },
          query: {filePath: filename}
    end
  end

  class Client
    include HistoricalData
  end

  module API
    module REST
      def parse_response response
        if response.starts_with?("{") || response.starts_with?("[")
          JSON.parse(response).tap { |r| handle_errors(r) }
        else
          response
        end
      end
    end
  end
end
HTTPI.logger = Rails.logger