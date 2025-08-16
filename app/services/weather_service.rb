# app/services/weather_service.rb
require 'net/http'
require 'uri'
require 'json'

class WeatherService
  BASE_API_URL = "https://api.openweathermap.org/data/2.5/weather"
  #defines here as well as need to set credentials file for live ao that it will run in any environment
  API_KEY = "5f5d7889e13de1de4eefdf9a1eabc1fa".strip

  def initialize(address)
    @address = address
  end

  def fetch_weather
    zip_code = extract_zip_code_from_address(@address)
    return nil unless zip_code
    #Rails.cache.fetch("weather_forecast_#{zip_code}", expires_in: 0.minutes) do
      uri = URI("#{BASE_API_URL}?zip=#{zip_code},us&appid=#{API_KEY}&units=imperial")
      response = Net::HTTP.get(uri)
      data = JSON.parse(response)
      {
        address: @address,
        zip: zip_code,
        temperature: data.dig("main", "temp"),
        high: data.dig("main", "temp_max"),
        low: data.dig("main", "temp_min"),
        feels_like: data.dig("main", "feels_like"),
        country: data.dig("sys", "country"),
        wind_speed: data.dig("wind", "speed"),
        name: data.dig("name"),
        description: data.dig("weather", 0, "description"),
        cached: false
      }
    #end
  end

  def cached?(zip)
    Rails.cache.exist?("weather_forecast_#{zip}")
  end

  private

  def extract_zip_code_from_address(address)
    # extract 5-digit ZIP from string or implement geocoder
    zip_code = address.to_s[/\d{5}/]
    return zip_code if zip_code.present?
  end

  def api_key
    Rails.application.credentials.dig(:openweather, :api_key) || API_KEY
  end
end
