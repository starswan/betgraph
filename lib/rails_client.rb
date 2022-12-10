# frozen_string_literal: true

#
# $Id$
#
class RailsClient
  class MarketParser
    def initialize(json)
      # @xml = Nokogiri.XML(xml, nil, 'ASCII_8BIT')
      @json = JSON.parse(json).symbolize_keys
    end

    def market_id
      # @xml.xpath('//id')[0].children[0].to_s.to_i
      @json.fetch(:id)
    end

    def active
      # @xml.xpath('//active')[0].children[0].to_s == 'true'
      @json[:active]
    end
  end

  def initialize(url, logger)
    @url = url
    @logger = logger
    @faraday = Faraday.new do |f|
      f.request :instrumentation
      f.response :raise_error
    end
  end

  def makeMarket(match, market)
    endpoint = "#{@url}/matches/#{match.id}/bet_markets.json"
    body = {
      bet_market: {
        marketid: market.marketId,
        name: market.name,
        markettype: market.marketType,
        status: "ACTIVE",
        live: false,
        runners_may_be_added: false,
        time: market.marketTime,
        exchange_id: market.exchangeId,
        number_of_winners: market.numberOfWinners,
        number_of_runners: 0,
        total_matched_amount: 0,
      },
    }
    @logger.debug "POST Request to #{endpoint} #{body}"
    response = post_json endpoint, body
    @logger.debug "Response from #{endpoint} #{response.body}"
    MarketParser.new response.body
  end

  ParsedMatch = Struct.new :id

  def makeMatch(division, kickofftime:, name:)
    match_type_param = division.calendar.sport.match_type.underscore
    match_type_url = match_type_param.pluralize

    endpoint = "#{@url}/divisions/#{division.id}/#{match_type_url}.json"
    body = { match_type_param.to_sym => {
      kickofftime: kickofftime,
      name: name,
    } }

    response = post_json endpoint, body
    json = JSON.parse(response.body).symbolize_keys
    @logger.debug "response #{json.inspect}"
    ParsedMatch.new json.fetch(:id)
  end

  def destroyMatch(match)
    endpoint = "#{@url}/matches/#{match.id}.json"
    @faraday.delete endpoint
  end

  def makeRunners(bet_market, marketdetail)
    endpoint = "#{@url}/matches/#{bet_market.match.id}/bet_markets/#{bet_market.id}.json"
    body = { bet_market: {
      runners_may_be_added: marketdetail.runnersMayBeAdded,
      live_priced: marketdetail.turningInPlay,
      live: marketdetail.turningInPlay,
    } }
    @faraday.put(endpoint, body.to_json, "Content-Type" => "application/json")
    if marketdetail.runners.empty?
      @logger.debug "Empty market detail: #{marketdetail.inspect}"
    else
      makeNewRunners bet_market, marketdetail
    end
  end

private

  def makeNewRunners(bm, marketdetail)
    runners = []
    marketdetail.runners.each_with_index do |runner, index|
      if bm.asian_handicap?
        @logger.debug "#{bm.name} making #{(index + 1).ordinalize} runner #{runner.name} hcap: #{runner.handicap}"
        runners << { name: runner.name, handicap: runner.handicap }
      else
        @logger.debug "#{bm.name} making #{(index + 1).ordinalize} runner #{runner.name}"
        runners << runner.name
      end
      # bm.market_runners.create!(:selectionId => runner.selectionId,
      #                          :asianLineId => runner.asianLineId,
      #                          :handicap    => runner.handicap,
      #                          :description => runner.name,
      #                          :sortorder   => i)
      endpoint = "#{@url}/bet_markets/#{bm.id}/market_runners.json"
      body = { market_runner:
                 { selectionId: runner.selectionId,
                   asianLineId: runner.asianLineId,
                   handicap: runner.handicap,
                   description: runner.name,
                   sortorder: index } }

      post_json endpoint, body
    end
    @logger.debug "Make ok #{bm.markettype} #{bm.name} runners #{runners.inspect}"
  end

  def post_json(endpoint, body)
    @logger.debug "POST to #{endpoint} #{body.inspect}"

    @faraday.send(:post) do |req|
      req.url(endpoint)
      req["Content-Type"] = "application/json"
      req.body = body.to_json
    end
  end
end
