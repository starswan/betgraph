class RapidApiJob < ApplicationJob
  HOSTNAME = "api-football-v1.p.rapidapi.com".freeze

protected

  def faraday
    Faraday.new(
      url: "https://#{HOSTNAME}",
      headers: {
        'X-RapidAPI-Key': ENV.fetch("RAPID_API_KEY"),
        'X-RapidAPI-Host': HOSTNAME,
      },
    ) do |f|
      f.request :instrumentation
      f.response :raise_error
      f.response :json, parser_options: { symbolize_names: true }
    end
  end
end
