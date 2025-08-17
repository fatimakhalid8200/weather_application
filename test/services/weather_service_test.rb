require "test_helper"

class WeatherServiceTest < ActiveSupport::TestCase
  def setup
    @service = WeatherService.new("95829")
  end

  test "should extract ZIP code from address" do
    zip = @service.send(:extract_zip_from_address, "Sacramento, CA 95829")
    assert_equal "95829", zip
  end

  test "should extract city from address" do
    city = @service.send(:extract_city_from_address, "95829, Sacramento County, California, United States")
    assert_equal "Sacramento", city
  end

  test "should have API key" do
    api_key = @service.send(:api_key)
    assert_not_nil api_key
    assert api_key.length > 0
  end

  test "should handle invalid address" do
    service = WeatherService.new("invalid_address_12345")
    result = service.fetch_weather
    assert_nil result
  end

  test "should handle empty address gracefully" do
    service = WeatherService.new("")
    result = service.fetch_weather
    assert_nil result
  end

  test "should extract Canadian postal code" do
    zip = @service.send(:extract_zip_from_address, "Toronto, ON M5V 3A8")
    assert_equal "M5V 3A8", zip
  end

  test "should extract UK postal code" do
    zip = @service.send(:extract_zip_from_address, "London SW1A 1AA")
    assert_equal "SW1A 1AA", zip
  end
end 