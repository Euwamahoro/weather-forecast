import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: const WeatherApp(),
    ),
  );
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: themeProvider.isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home: const WeatherHomePage(),
    );
  }
}

// this for managing dark/light theme
class ThemeProvider with ChangeNotifier {
  bool isDarkTheme = false;

  void toggleTheme() {
    isDarkTheme = !isDarkTheme;
    notifyListeners();
  }
}

// here I am managing weather API responses
class WeatherProvider with ChangeNotifier {
  String weatherInfo = '';

  Future<void> fetchWeather(String city) async {
    const apiKey = 'af3ef58adc2c6d98b42aa785fb638cf5';
    final apiUrl =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final temperature = (data['main']['temp'] - 273.15).toStringAsFixed(1);
        final description = data['weather'][0]['description'];
        weatherInfo = 'Temperature: $temperature°C\nDescription: $description';
      } else {
        weatherInfo = 'City not found. Please enter a valid city.';
      }
    } catch (error) {
      weatherInfo = 'Error fetching weather data.';
    }
    notifyListeners();
  }

  void resetWeatherInfo() {
    weatherInfo = '';
    notifyListeners();
  }
}

class WeatherHomePage extends StatelessWidget {
  const WeatherHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final weatherProvider = Provider.of<WeatherProvider>(context);

    final TextEditingController cityController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkTheme
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: themeProvider.isDarkTheme
                ? [Colors.black, Colors.grey.shade900]
                : [Colors.blue.shade100, Colors.blue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: cityController,
                decoration: const InputDecoration(
                  labelText: 'Enter city',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (cityController.text.isNotEmpty) {
                    weatherProvider.fetchWeather(cityController.text);
                  } else {
                    weatherProvider.weatherInfo = 'Please enter a city.';
                  }
                },
                child: const Text('Get Weather'),
              ),
              const SizedBox(height: 20),
              Consumer<WeatherProvider>(
                builder: (context, provider, child) {
                  return Text(
                    provider.weatherInfo,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const WeatherFactsPage()),
                      );
                    },
                    child: const Text('Weather Facts'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const EnvironmentalTipsPage()),
                      );
                    },
                    child: const Text('Environmental Tips'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WeatherFactsPage extends StatelessWidget {
  const WeatherFactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather Facts')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Did you know?\n\n1. Antarctica holds the record for the coldest temperature ever recorded on Earth: -89.2°C.\n'
          '2. Clouds can weigh millions of kilograms!\n'
          '3. Rain doesn’t always land as water; sometimes it freezes and falls as hail!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

class EnvironmentalTipsPage extends StatelessWidget {
  const EnvironmentalTipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Environmental Tips')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Let\'s save the environment!\n\n1. Reduce, reuse, and recycle to minimize waste.\n'
          '2. Save energy by turning off lights and electronics when not in use.\n'
          '3. Plant trees to improve air quality and biodiversity.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

