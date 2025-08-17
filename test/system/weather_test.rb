require "application_system_test_case"

class WeatherTest < ApplicationSystemTestCase
  def setup
    Rails.cache.clear
  end

  test "page loads" do
    visit root_url
    assert_selector "h1", text: "Weather Forecast"
  end

  test "can search" do
    visit root_url
    fill_in "address", with: "95829"
    click_on "Search"
    assert_selector ".weather-data"
  end

  test "wrong input shows error" do
    visit root_url
    fill_in "address", with: "invalid"
    click_on "Search"
    assert_selector "#error-message"
  end

  test "whitespace shows error" do
    visit root_url
    fill_in "address", with:"   "
    click_on "Search"
    assert_selector "#error-message"    
  end

  test "empty input shows error" do
    visit root_url
    fill_in "address", with: ""
    click_on "Search"
    assert_selector "#error-message"
  end
  
  test "can search multiple times" do
    visit root_url
    fill_in "address", with: "95829"
    click_on "Search"
    assert_selector ".weather-data"
    
    fill_in "address", with: "90210"
    click_on "Search"
    assert_selector ".weather-data"
  end

  test "enter key works" do
    visit root_url
    fill_in "address", with: "95829"
    find("#address-input").send_keys :enter
    assert_selector ".weather-data"
  end

  test "form elements exist" do
    visit root_url
    assert_selector ".search-form"
    assert_selector "input[type=text]"
  end
end 