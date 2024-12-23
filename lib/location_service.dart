import 'package:geolocator/geolocator.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

Future<mapbox.Position> getUserLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Check if location services are enabled
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception("Location services are disabled.");
  }

  // Check location permissions
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception("Location permissions denied.");
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception("Location permissions are permanently denied.");
  }

  // Get current location
  final geoPosition = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high
  );
  
  // Convert to Mapbox Position
  return mapbox.Position(
    geoPosition.longitude,
    geoPosition.latitude
  );
}
