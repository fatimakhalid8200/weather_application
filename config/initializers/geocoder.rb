# Geocoder configuration for ZIP code lookups
Geocoder.configure(
  lookup: :nominatim,
  http_headers: { "User-Agent" => "MyRailsApp" },
  timeout: 5
)