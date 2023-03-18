import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var temperature;
  var currently;
  var humidity;
  var windSpeed;

  Position? _currentPosition;

  Future<void> _getCurrentLocation() async {
    // 位置情報へのアクセス許可を確認する
    await _getLocationPermission();

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });
  }

  Future<PermissionStatus> _getLocationPermission() async {
    PermissionStatus permission = await Permission.location.status;
    if (permission != PermissionStatus.granted &&
        permission != PermissionStatus.denied) {
      // ユーザーがまだ許可を与えていない場合は、リクエストする
      permission = await Permission.location.request();
    }
    if (permission == PermissionStatus.denied) {
      permission = await Permission.location.request();
      // throw Exception('Location permission denied');
    }
    return permission;
  }

  Future<void> _getWeather() async {
    final weatherUrl = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=${_currentPosition!.latitude}&lon=${_currentPosition!.longitude}&appid=YOUR_API_KEY&units=metric');

    final response = await http.get(weatherUrl);

    final data = jsonDecode(response.body);
    setState(() {
      temperature = data['main']['temp'];
      currently = data['weather'][0]['description'];
      humidity = data['main']['humidity'];
      windSpeed = data['wind']['speed'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'Weather App',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              if (_currentPosition == null)
                ElevatedButton(
                  child: Text('Get Location'),
                  onPressed: _getCurrentLocation,
                ),
              if (_currentPosition != null)
                ElevatedButton(
                  child: Text('Get Weather'),
                  onPressed: _getWeather,
                ),
              if (temperature != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    'Temperature: ${temperature.toString()}°C',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              if (currently != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    'Currently: ${currently.toString()}',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              if (humidity != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    'Humidity: ${humidity.toString()}%',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              if (windSpeed != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    'Wind Speed: ${windSpeed.toString()} m/s',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
