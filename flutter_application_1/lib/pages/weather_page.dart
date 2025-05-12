import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_application_1/service/weather_service.dart';
import '../models/weather_model.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
// api key
  final _weatherService = WeatherServices("256d855cfcd38681e02a098757c3d487");
  Weather? _weather;
// get weather
  fetchWeather() async {
    //get current city
    String cityName = await _weatherService.getCurrentCity();

    // get weather for current city
    try {
      final weather = await _weatherService.getWeather(cityName);
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    // get weather
    fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black12,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // city name
              Text(
                _weather?.cityName ?? "Loading City...",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
              ),

              // city temperature
              Text(
                "${_weather?.temperature.round() ?? ""}°C",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              //weather condition
              Text(
                "${_weather?.mainCondition}",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
        ));
  }
}