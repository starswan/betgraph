module Betfair
  class Client
    def keep_alive
      get url: "https://identitysso-cert.betfair.com/api/keepAlive"
    end
  end
end
HTTPI.logger = Rails.logger