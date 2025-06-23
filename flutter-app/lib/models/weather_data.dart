class WeatherData {
  final double temperature;
  final String description;
  final int humidity;
  final double windSpeed;
  final String location;
  final String icon;

  WeatherData({
    required this.temperature,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.location,
    required this.icon,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'],
      humidity: json['main']['humidity'],
      windSpeed: (json['wind']['speed'] as num).toDouble(),
      location: json['name'],
      icon: json['weather'][0]['icon'],
    );
  }

  /// Get weather icon URL
  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';

  /// Get temperature with appropriate unit
  String get temperatureDisplay => '${temperature.round()}°C';

  /// Get weather description with proper capitalization
  String get descriptionDisplay => description
      .split(' ')
      .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join(' ');

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'description': description,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'location': location,
      'icon': icon,
    };
  }

  @override
  String toString() {
    return 'WeatherData(temperature: $temperature, description: $description, location: $location)';
  }
}
