# app/controllers/weather_controller.rb - handles weather search and display
class WeatherController < ApplicationController

  # Main action - shows search form and handles AJAX weather requests
  def index
    # Handle AJAX requests for weather data
    if request.xhr? && params[:address].present?
      # Get weather data from service
      service = WeatherService.new(params[:address])
      @forecast = service.fetch_weather

      if @forecast && @forecast[:temperature].present?
        # Return weather data for display
        respond_to do |format|
          format.js { render :show_weather }
        end
      else
        # Show error if weather data couldn't be fetched
        respond_to do |format|
          format.js { render :show_error }
        end
      end
    end
    # For regular page loads, just show the search form
  end

  # Old show action - kept for reference but not used anymore
  # We switched to single-page app with AJAX instead
  # def show
  #   # POST Request
  #   byebug
  #   if request.post?
  #     Rails.logger.info "Processing POST request for weather"
  #     service = WeatherService.new(params[:address])
  #     @forecast = service.fetch_weather

  #     if @forecast
  #       # Store forecast data in session and redirect to GET show
  #       session[:forecast_data] = @forecast
  #       Rails.logger.info "Stored forecast data in session: #{@forecast.inspect}"
  #       byebug
  #       redirect_to weather_path(@forecast[:zip])
  #     else
  #       flash[:alert] = "Invalid address or unable to fetch weather."
  #       redirect_to root_path
  #     end
  #   else
  #     byebug
  #     # GET Request
  #     Rails.logger.info "Processing GET request for weather with zip: #{params[:zip]} && Data: #{session[:forecast_data].inspect}"
      
  #     session_data = session[:forecast_data]
  #     if session_data && (session_data[:zip] == params[:zip] || session_data["zip"] == params[:zip])
  #       # Convert string keys to symbol keys
  #       @forecast = session_data.transform_keys(&:to_sym)
  #       # Clear the session data after displaying
  #       session.delete(:forecast_data)
  #       Rails.logger.info "Displaying forecast data: #{@forecast.inspect}"
  #     else
  #       Rails.logger.error "No valid forecast data found in session"
  #       flash[:alert] = "No weather data available."
  #       redirect_to root_path
  #     end
  #   end
  # end
end
