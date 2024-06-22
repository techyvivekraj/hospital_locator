import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hospital_locator/utils/images_const.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapService {
  BitmapDescriptor hospitalIcon = BitmapDescriptor.defaultMarker;
  String googleKey = "replae me";
  Future<Position> getCurrentLocation() async {
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

    return await Geolocator.getCurrentPosition();
  }

  Future<List<Marker>> getNearbyHospitals(LatLng location) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${location.latitude}, ${location.longitude}&radius=1500&type=hospital&key=$googleKey';
    final response = await http.get(Uri.parse(url));
    final json = jsonDecode(response.body);
    final List<dynamic> results = json['results'];
    return results.map((hospital) {
      return Marker(
        icon: hospitalIcon,
        markerId: MarkerId(hospital['place_id']),
        position: LatLng(hospital['geometry']['location']['lat'],
            hospital['geometry']['location']['lng']),
        infoWindow:
            InfoWindow(title: hospital['name'], snippet: hospital['vicinity']),
      );
    }).toList();
  }

  Future<void> setCustomMarkerIcon() async {
    BitmapDescriptor.asset(ImageConfiguration.empty, ImagesConst.hospitalIcon)
        .then(
      (icon) {
        hospitalIcon = icon;
      },
    );
  }
}
