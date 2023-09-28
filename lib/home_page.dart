import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position? position;

  determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    position = await Geolocator.getCurrentPosition();
    setState(() {
      latitude = position!.latitude;
      longitude = position!.longitude;
    });

    fetchWeatherData();
  }

  var latitude;
  var longitude;

  Map<String, dynamic>? weatherMap;
  Map<String, dynamic>? forecastMap;

  fetchWeatherData() async {
    String WeatherUrl =
        "https://api.openweathermap.org/data/2.5/weather?lat=latitude&lon=longitude&units=metric&appid=f92bf340ade13c087f6334ed434f9761&fbclid=IwAR0vlebaouEmURClRdtuWEg7qeBOdbDxmQ5HM9JDJL_mj5uDS7xqy4kCGTQ";
    String ForecastUrl =
        "https://api.openweathermap.org/data/2.5/forecast?lat=latitude&lon=longitude&units=metric&appid=f92bf340ade13c087f6334ed434f9761&fbclid=IwAR0vlebaouEmURClRdtuWEg7qeBOdbDxmQ5HM9JDJL_mj5uDS7xqy4kCGTQ";

    var weatherResponse = await http.get(Uri.parse(WeatherUrl));
    var forecastResponse = await http.get(Uri.parse(ForecastUrl));
    weatherMap = Map<String, dynamic>.from(jsonDecode(weatherResponse.body));
    forecastMap = Map<String, dynamic>.from(jsonDecode(forecastResponse.body));
    setState(() {});

      print("Weather Response is $latitude,$longitude");

  }

  @override
  void initState() {
    // TODO: implement initState
    determinePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //var isLoaded;
    return SafeArea(
      child: Scaffold(

        //appBar: AppBar(title: Text("Weather App"), centerTitle: true),
          body: Container(
            height: 400,
            width: double.infinity,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(
                        "https://msfsaddons.com/wp-content/uploads/2022/07/1b.jpg?ezimgfmt=ngcb12/notWebP"),
                    fit: BoxFit.cover)),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Column(
                    children: [
                      Text("${Jiffy(DateTime.now()).format("ddMMM yyyy, h:mm a")}"),
                      Text(("${weatherMap!["name"]}"))
                    ],
                  ),
                ),
                Text("${weatherMap!["main"]["temp"]} °"),
                const Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    children: [Text("data")],
                  ),
                )
              ],
            ),
          )),
    );
  }
}
