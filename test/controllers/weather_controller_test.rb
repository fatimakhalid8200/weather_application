require "test_helper"

class WeatherControllerTest < ActionDispatch::IntegrationTest
  test "homepage works" do
    get root_url
    assert_response :success
  end

  test "search works" do
    get root_url, params: { address: "95829" }
    assert_response :success
  end

  test "ajax works" do
    get root_url, params: { address: "95829" }, 
        headers: { "X-Requested-With" => "XMLHttpRequest" }
    assert_response :success
  end

  test "empty input ok" do
    get root_url, params: { address: "" }
    assert_response :success
  end
end 