import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:intl/intl.dart';
import 'package:weatherapp/additional_information_item.dart';
import 'package:weatherapp/secrets.dart';
import 'hourly_forecast_item.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weather;
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = 'Kota,IN';
      final result = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$cityName&APPID=$openWeatherAPIKey',
        ),
      );

      final data = jsonDecode(result.body);

      if (data['cod'] != 200) {
        throw 'An Unexpexted Error Occured';
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weather = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              setState(() {
                weather = getCurrentWeather();
              });
            },
            borderRadius: BorderRadius.circular(200.0),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.refresh),
            ),
          ),
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context, snapshot) {
          print(snapshot);

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }

          final data = snapshot.data!;

          final currentTemp = (data['main']['temp'] - 273.15);
          final humidity = data['main']['humidity'];
          final pressure = data['main']['pressure'];
          final windSpeed = data['wind']['speed'];
          final currentSky = data['weather'][0]['main'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '${currentTemp.toStringAsFixed(2)}°C',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                currentSky == 'Clouds' || currentSky == 'Rain'
                                    ? Icons.cloud
                                    : Icons.sunny,
                                size: 64,
                                color: Colors.white,
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Text(
                                currentSky,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Weather Forecast',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal, // Maintain horizontal scrolling
                    itemCount: 8, // Same as before
                    itemBuilder: (context, index) {
                      return HourlyForecastItem(
                        time: DateFormat('hh:mm a').format(
                          DateTime.fromMillisecondsSinceEpoch(
                            data['dt'] * 1000 + (index * 3600 * 1000), // Adding index hours dynamically
                          ),
                        ), // Convert to 12-hour format
                        icon: data['weather'][0]['main'] == 'Clouds' || data['weather'][0]['main'] == 'Rain'
                            ? Icons.cloud
                            : Icons.sunny, // Dynamically change icon based on weather condition
                        value: '${(data['main']['temp'] - 273.15).toStringAsFixed(2)}°C', // Convert Kelvin to Celsius
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'Additional Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInformationItem(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: '$humidity',
                    ),
                    AdditionalInformationItem(
                      icon: Icons.air,
                      label: 'Wind Speed',
                      value: '$windSpeed',
                    ),
                    AdditionalInformationItem(
                      icon: Icons.beach_access,
                      label: 'Pressure',
                      value: '$pressure',
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
