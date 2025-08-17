# WeatherService - handles weather API calls and caching
require 'net/http'
require 'uri'
require 'json'

class WeatherService
  # OpenWeatherMap API endpoint
  BASE_API_URL = "https://api.openweathermap.org/data/2.5/weather"
  
  # API key - move to environment variables in production
  API_KEY = "5f5d7889e13de1de4eefdf9a1eabc1fa".strip

  def initialize(address)
    @address = address
  end

  # Get weather data for the address, with 30-minute caching
  def fetch_weather
    # Extract ZIP code from address
    zip_code = extract_zip_code_from_address(@address)
    return nil unless zip_code
    
    # Check if we already have cached data
    was_cached = Rails.cache.exist?("weather_forecast_#{zip_code}")
    
    # Get weather data (from cache or API)
    weather_data = Rails.cache.fetch("weather_forecast_#{zip_code}", expires_in: 30.minutes) do
      # Make API call to OpenWeatherMap
      uri = URI("#{BASE_API_URL}?zip=#{zip_code},us&appid=#{API_KEY}&units=imperial")
      response = Net::HTTP.get(uri)
      data = JSON.parse(response)
      
      #Response data
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
    end
    
    # Set cache status
    weather_data[:cached] = was_cached
    weather_data
  rescue StandardError => e
    # Error Logging
    Rails.logger.error "Weather API error: #{e.message}"
    nil
  end

  # Check if weather data is cached for a ZIP code
  def cached?(zip)
    Rails.cache.exist?("weather_forecast_#{zip}")
  end

  private

  # Extract 5-digit ZIP code from address
  def extract_zip_code_from_address(address)
    zip_code = address.to_s[/\d{5}/]
    return zip_code if zip_code.present?
  end

  # Get API key from credentials or environment
  def api_key
    # Right now I havee mentioned this in this file as constant just for local testing
    Rails.application.credentials.dig(:openweather, :api_key) || 
    ENV['OPENWEATHER_API_KEY'] || 
    API_KEY
  end
end
