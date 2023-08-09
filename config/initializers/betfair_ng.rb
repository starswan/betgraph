module Betfair
  module Streaming
    # stream-api.betfair.com for live
    STREAM_HOST = 'stream-api-integration.betfair.com'

    class StreamSocket
      include Enumerable

      def initialize host, cert_key_file_path, cert_file_path, token
        socket = TCPSocket.open(host,443)
        ssl_context = OpenSSL::SSL::SSLContext.new
        # ssl_context.cert = OpenSSL::X509::Certificate.new(File.open("certificate.crt"))
        ssl_context.cert = OpenSSL::X509::Certificate.new(File.open(cert_file_path))
        # ssl_context.key = OpenSSL::PKey::RSA.new(File.open("certificate.key"))
        ssl_context.key = OpenSSL::PKey::RSA.new(File.open(cert_key_file_path))
        # ssl_context.ssl_version = :SSLv23
        @ssl_socket = OpenSSL::SSL::SSLSocket.new(socket, ssl_context)
        @ssl_socket.sync_close = true
        @ssl_socket.connect

        # have got a connection, but my delayed API key doesn't support streaming
        # have raised a support ticket with Betfair 10/Aug/2023
        connection = @ssl_socket.gets
        Rails.logger.info "Receeived connection string #{connection}"

        json_auth = {
          op: "authentication",
          appKey: ENV["BETFAIR_API_KEY"],
          session: token
        }.to_json
        Rails.logger.info("Sending #{json_auth}")
        @ssl_socket.puts json_auth
      end

      def each
        while line = @ssl_socket.gets
          yield line
        end
        @ssl_socket.close
      end
    end

    def stream username, password, cert_key_file_path, cert_file_path
      # non_interactive_login username, password, cert_key_file_path, cert_file_path
      # def non_interactive_login(username, password, cert_key_file_path, cert_file_path)
      json = post({
                    url: "https://identitysso-cert.betfair.com/api/certlogin",
                    body: { username: username, password: password },
                    headers: { "Content-Type"  => "application/x-www-form-urlencoded" },
                    cert_key_file_path: cert_key_file_path,
                    cert_file_path: cert_file_path
                  })
      #
      #   add_session_token_to_persistent_headers(json["sessionToken"])
      # end

      # require 'socket'
      # require 'openssl'
      #
      @stream ||= StreamSocket.new STREAM_HOST, cert_key_file_path, cert_file_path, json["sessionToken"]
    end
  end

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
    include Streaming
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