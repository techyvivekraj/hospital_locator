import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hospital_locator/services/map_service.dart';
import 'package:hospital_locator/services/login_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _controller;
  LatLng currentLatLng = const LatLng(26.572384675330877, 85.4780245232749);
  Set<Marker> _markers = {};
  LoginService loginService = LoginService();

  MapService mapService = MapService();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    mapService.setCustomMarkerIcon();
    _loadMap();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _formKey.currentState!.dispose();
    super.dispose();
  }

  Future<void> _loadMap() async {
    try {
      Position position = await mapService.getCurrentLocation();
      _controller.moveCamera(CameraUpdate.newLatLng(currentLatLng));
      List<Marker> markers = await mapService.getNearbyHospitals(currentLatLng);
      setState(() {
        currentLatLng = LatLng(position.latitude, position.longitude);
        _markers = markers.toSet();
      });
    } catch (e) {
      print('Error loading map: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _formKey,
      appBar: AppBar(
        title: const Text("Hospital Locator"),
        actions: [
          IconButton(
              onPressed: () async {
                await loginService.signOut();
                Navigator.pushReplacementNamed(context, '/');
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: SafeArea(
        child: GoogleMap(
          zoomControlsEnabled: false,
          onMapCreated: (controller) => _controller = controller,
          initialCameraPosition:
              CameraPosition(target: currentLatLng, zoom: 14.0),
          markers: _markers,
        ),
      ),
      floatingActionButton: IconButton.filled(
          color: Colors.white,
          icon: const Icon(Icons.my_location),
          onPressed: () {
            _loadMap();
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
