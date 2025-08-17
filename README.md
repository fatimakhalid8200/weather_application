## Weather Forecast Application

A simple weather application built with Ruby on Rails that shows current weather information for any location by ZIP code or complete address.

## Features

- Shows current temperature, conditions, and high/low temps
- Caches results for 30 minutes (faster repeat searches)
- Works on phones and computers
- No page reloads - smooth experience

## Tech Stack

- Backend: Ruby on Rails 8.0.2
- Database**: PostgreSQL  
- Caching: Rails.cache (30-minute expiration)
- Weather API**: OpenWeatherMap
- Frontend: HTML, CSS, JavaScript

## Start

## Prerequisites

- Make sure you have installed:
- Ruby 3.3.6  
- Rails 8.0
- PostgreSQL  

1. Get the code
   <!-- ```bash -->
   git clone https://github.com/fatimakhalid8200/weather_application
   cd weather_application
   bundle install
   
2. Databse setup
   ```bash
   rails db:create
   rails db:migrate
   ```

3. Add Weather Api
   ```bash
   rails credentials:edit
   ```
   Add this inside:
   ```yaml
   openweather:
     api_key: "your_api_key_here"
   ```

4. Start the app
   ```bash
   rails server
   ```

5. Visit http://localhost:3000

**For New API key need to signin or Sigup up to OpenWeaterMap(https://openweathermap.org/) and get key from dashboard.**

## How it's built

The app is broken down into focused pieces that each do one job well:

### WeatherController
Handles web requests from users
- Takes ZIP codes or city name/address from the search form
- Calls the service to get weather data
- Returns the response (HTML or JavaScript)

### WeatherService  
Runs Operations
- Uses Geocoder to find location details (ZIP, city, country)
- Call the weather API to get data
- Store result in Cache for 30 minutes
- Formats the data

### Views
Shows everything to users
- Search form for entering address or ZIP code
- Display weather with temperature and conditions 
- Shows error message when something goes wrong

## Why this design works

**Service Layer Pattern** - Keeps business logic separate from web stuff
- WeatherService handles all the API and caching work
- Controller just handles web requests
- Makes the code easier to test and fix

**Single Page Application** - Modern web approach
- One page that updates dynamically
- No full page reloads needed
- Smoother user experience

**Caching** - Makes it fast
- Stores weather data for 30 minutes
- Reduces API calls (saves money and time)
- Shows users if data is fresh or from cache

## Testing

```bash
# Run all tests
rails test

# Run specific test files
rails test test/controllers/weather_controller_test.rb
rails test test/services/weather_service_test.rb
rails test test/system/weather_test.rb
```