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
    # Use Geocoder gem to get location data
    location_data = get_location_data(@address)
    return nil unless location_data
    
    # Create cache key from location data
    cache_key = "weather_forecast_#{location_data[:zip] || location_data[:city]}_#{location_data[:country]}"
    
    # Check if we already have cached data
    was_cached = Rails.cache.exist?(cache_key)
    
    # Get weather data (from cache or API)
    weather_data = Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
      # Call OpenWeather API with location data
      fetch_weather_from_api(location_data)
    end
    
    # Set cache status
    weather_data[:cached] = was_cached
    weather_data
  rescue StandardError => e
    # Error Logging
    Rails.logger.error "Weather API error: #{e.message}"
    nil
  end

  # Check if weather data is cached for a location
  def cached?(location)
    location_data = get_location_data(location)
    return false unless location_data
    
    cache_key = "weather_forecast_#{location_data[:zip] || location_data[:city]}_#{location_data[:country]}"
    Rails.cache.exist?(cache_key)
  end

  private

  # Use Geocoder to get location details (ZIP, city, country)
  def get_location_data(address)
    begin
      # Use Geocoder to find location
      result = Geocoder.search(address).first
      return nil unless result
      
      Rails.logger.debug "Geocoder result: #{result.inspect}"
      
      # Extract location details - use only methods that exist
      location_data = {
        zip: extract_zip_from_result(result),
        city: result.city || result.municipality || extract_city_from_address(result.address),
        country: result.country_code&.downcase,
        latitude: result.latitude,
        longitude: result.longitude,
        formatted_address: result.address
      }
      
      Rails.logger.debug "Extracted location data: #{location_data}"
      location_data
    rescue => e
      Rails.logger.warn "Geocoder error for address '#{address}': #{e.message}"
      nil
    end
  end

  # Extract ZIP code from Geocoder result
  def extract_zip_from_result(result)
    # Debug: let's see what methods are available
    Rails.logger.debug "Geocoder result methods: #{result.methods.grep(/postal|zip|code/)}"
    
    # Try different ways to get ZIP code
    zip = extract_zip_from_address(result.address)
    
    return zip if zip.present?
  end

  # Extract ZIP code from address string
  def extract_zip_from_address(address)
    return nil unless address.present?
    
    Rails.logger.debug "Extracting ZIP from address: #{address}"
    
    # Try ZIP code patterns
    patterns = [
      /\b\d{5}\b/,           # US 5-digit ZIP
      /\b[A-Z]\d[A-Z]\s?\d[A-Z]\d\b/i,  # Canadian postal code
      /\b[A-Z]{1,2}\d[A-Z\d]?\s?\d[A-Z]{2}\b/i,  # UK postal code
      /\b\d{4}\s?[A-Z]{2}\b/i,  # Dutch postal code
      /\b\d{5}\s?\d{4}\b/,   # US ZIP+4
      /\b\d{4}\b/            # 4-digit codes (some countries)
    ]
    
    patterns.each do |pattern|
      match = address.match(pattern)
      if match
        Rails.logger.debug "Found ZIP code: #{match[0]} with pattern: #{pattern}"
        return match[0]
      end
    end
    
    Rails.logger.debug "No ZIP code found in address"
    nil
  end

  # Extract city name from address string
  def extract_city_from_address(address)
    return nil unless address.present?
    
    Rails.logger.debug "Extracting city from address: #{address}"
    
    address_parts = address.split(',')
    
    # Look for city in the address parts (usually after ZIP code)
    address_parts.each do |part|
      part = part.strip
      # Skip if it's a ZIP code, state, or country
      next if part.match?(/\d{5}/) || part.match?(/^[A-Z]{2}$/) || 
              part.match?(/United States|Canada|UK|Germany|France/i)
      
      # If it looks like a city name (not empty, not just numbers, contains "County" or looks like a city)
      if part.present? && !part.match?(/^\d+$/) && part.length > 2
        # Remove "County" suffix if present
        city_name = part.gsub(/\s+County$/, '')
        Rails.logger.debug "Found city: #{city_name}"
        return city_name
      end
    end
    
    Rails.logger.debug "No city found in address"
    nil
  end

  # Call OpenWeather API with location data
  def fetch_weather_from_api(location_data)
    # Build API URL based on available data
    if location_data[:zip] && location_data[:country]
      # Use ZIP + country if available
      uri = URI("#{BASE_API_URL}?zip=#{location_data[:zip]},#{location_data[:country]}&appid=#{api_key}&units=imperial")
    elsif location_data[:city] && location_data[:country]
      # Use city + country if ZIP not available
      uri = URI("#{BASE_API_URL}?q=#{location_data[:city]},#{location_data[:country]}&appid=#{api_key}&units=imperial")
    elsif location_data[:latitude] && location_data[:longitude]
      # Use coordinates as fallback
      uri = URI("#{BASE_API_URL}?lat=#{location_data[:latitude]}&lon=#{location_data[:longitude]}&appid=#{api_key}&units=imperial")
    else
      # Try just the city name
      uri = URI("#{BASE_API_URL}?q=#{location_data[:city]}&appid=#{api_key}&units=imperial")
    end
    
    response = Net::HTTP.get(uri)
    data = JSON.parse(response)
    
    # Return formatted weather data
    {
      address: @address,
      zip: location_data[:zip],
      city: location_data[:city],
      country: location_data[:country],
      temperature: data.dig("main", "temp"),
      high: data.dig("main", "temp_max"),
      low: data.dig("main", "temp_min"),
      feels_like: data.dig("main", "feels_like"),
      wind_speed: data.dig("wind", "speed"),
      name: data.dig("name"),
      description: data.dig("weather", 0, "description"),
      cached: false
    }
  end

  # Get API key from credentials or environment
  def api_key
    # Right now I havee mentioned this in this file as constant just for local testing
    Rails.application.credentials.dig(:openweather, :api_key) || 
    ENV['OPENWEATHER_API_KEY'] || 
    API_KEY
  end
end
