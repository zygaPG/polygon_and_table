import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:polgon_and_table/map_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  String ACCESS_TOKEN = const String.fromEnvironment("ACCESS_TOKEN");
  MapboxOptions.setAccessToken(ACCESS_TOKEN);

  runApp(MaterialApp(home: MapPage()));
}
