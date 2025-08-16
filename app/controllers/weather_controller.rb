# app/controllers/weather_controller.rb
class WeatherController < ApplicationController

  # GET /weather or /weather.json
  def index
  end

  # POST /weather - Process form and redirect to show
  def show
    # POST Request
    if request.post?
      Rails.logger.info "Processing POST request for weather"
      service = WeatherService.new(params[:address])
      @forecast = service.fetch_weather

      if @forecast
        @forecast[:cached] = service.cached?(@forecast[:zip])
        # Store forecast data in session and redirect to GET show
        session[:forecast_data] = @forecast
        Rails.logger.info "Stored forecast data in session: #{@forecast.inspect}"
        redirect_to "/weather/#{@forecast[:zip]}"
      else
        flash[:alert] = "Invalid address or unable to fetch weather."
        redirect_to root_path
      end
    else
      # GET Request
      Rails.logger.info "Processing GET request for weather with zip: #{params[:zip]} && Data: #{session[:forecast_data].inspect}"
      
      session_data = session[:forecast_data]
      if session_data && (session_data[:zip] == params[:zip] || session_data["zip"] == params[:zip])
        # Convert string keys to symbol keys
        @forecast = session_data.transform_keys(&:to_sym)
        # Clear the session data after displaying
        session.delete(:forecast_data)
        Rails.logger.info "Displaying forecast data: #{@forecast.inspect}"
      else
        Rails.logger.error "No valid forecast data found in session"
        flash[:alert] = "No weather data available."
        redirect_to root_path
      end
    end
  end
end
