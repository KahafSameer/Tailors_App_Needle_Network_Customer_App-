// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, file_names, prefer_const_constructors_in_immutables, use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:needle_network_main/Data_Provider.dart';
import 'package:provider/provider.dart';

class LocationSetup extends StatefulWidget {
  LocationSetup({
    Key? key,
  }) : super(key: key);

  @override
  State<LocationSetup> createState() => _LocationSetupState();
}

class _LocationSetupState extends State<LocationSetup> {
  Position? _currentPosition;
  LatLng? coordinates;
  Placemark? placemark;
  String? street;
  String? city;
  String? state;
  String? country;
  String? completeAddress;

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  CameraPosition get currentCameraPosition => CameraPosition(
        bearing: 192.8334901395799,
        target: _currentPosition != null
            ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
            : const LatLng(0, 0),
        tilt: 59.440717697143555,
        zoom: 20,
      );

  Set<Marker> markers = {};

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permissions are denied.');
        return;
      }
    }

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    setState(() {
      _currentPosition = position;
      coordinates = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.blue),
        ),
      );
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.blue),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Set Your Location",
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.blue),
              tooltip: "Search Location",
              onPressed: () async {
                final address = await showDialog<String>(
                  context: context,
                  builder: (context) {
                    String input = '';
                    return AlertDialog(
                      title: const Text('Search Location'),
                      content: TextField(
                        autofocus: true,
                        decoration: const InputDecoration(
                            hintText: 'Enter address or city'),
                        onChanged: (value) => input = value,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, null),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, input),
                          child: const Text('Search'),
                        ),
                      ],
                    );
                  },
                );
                if (address != null && address.trim().isNotEmpty) {
                  try {
                    List<Location> locations =
                        await locationFromAddress(address);
                    if (locations.isNotEmpty) {
                      final pos =
                          LatLng(locations[0].latitude, locations[0].longitude);
                      final GoogleMapController controller =
                          await _controller.future;
                      controller.animateCamera(CameraUpdate.newLatLng(pos));
                      markers.clear();
                      markers.add(
                        Marker(
                          markerId: MarkerId('${pos.latitude}${pos.longitude}'),
                          position: pos,
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueAzure),
                          onTap: () {
                            setState(() {
                              markers.clear();
                              completeAddress = null;
                              coordinates = null;
                            });
                          },
                        ),
                      );
                      List<Placemark> placemarks =
                          await placemarkFromCoordinates(
                              pos.latitude, pos.longitude);
                      street = placemarks[0].street ?? "";
                      city = placemarks[0].locality ?? "";
                      state = placemarks[0].administrativeArea ?? "";
                      country = placemarks[0].country ?? "";
                      completeAddress = "$street, $city, $state, $country";
                      coordinates = pos;
                      setState(() {});
                    } else {
                      Fluttertoast.showToast(msg: 'Location not found');
                    }
                  } catch (e) {
                    Fluttertoast.showToast(msg: 'Location not found');
                  }
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Icon(
                    completeAddress == null
                        ? Icons.location_on_outlined
                        : Icons.location_on,
                    color: Colors.blue,
                    size: 32,
                  ),
                  title: Text(
                    completeAddress ?? "Choose your location",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          completeAddress == null ? Colors.grey : Colors.blue,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: completeAddress != null
                      ? const Text(
                          "Tap on the map to change location",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        )
                      : null,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: currentCameraPosition,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                    markers: markers,
                    onTap: (pos) async {
                      markers.clear();
                      List<Placemark> placemarks =
                          await placemarkFromCoordinates(
                              pos.latitude, pos.longitude);
                      coordinates = pos;
                      street = placemarks[0].street ?? "";
                      city = placemarks[0].locality ?? "";
                      state = placemarks[0].administrativeArea ?? "";
                      country = placemarks[0].country ?? "";
                      completeAddress = "$street, $city, $state, $country";

                      markers.add(
                        Marker(
                          markerId: MarkerId('${pos.latitude}${pos.longitude}'),
                          position: LatLng(pos.latitude, pos.longitude),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueAzure),
                          onTap: () {
                            setState(() {
                              markers.clear();
                              completeAddress = null;
                              coordinates = null;
                            });
                          },
                        ),
                      );
                      setState(() {});
                    },
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: const Text(
                    'Set Location',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    if (completeAddress == null || coordinates == null) {
                      Fluttertoast.showToast(msg: 'Please select a location');
                      return;
                    }
                    bool locationSaved =
                        await Provider.of<DataProvider>(context, listen: false)
                            .saveLocation(completeAddress!,
                                coordinates!.latitude, coordinates!.longitude);
                    if (locationSaved) {
                      Navigator.pop(context, true);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.small(
          heroTag: 'locationsetup_fab',
          backgroundColor: Colors.white,
          tooltip: "Go to my location",
          elevation: 2,
          child: const Icon(Icons.gps_fixed, color: Colors.blue),
          onPressed: () async {
            await _getCurrentLocation();
            if (_currentPosition != null) {
              final GoogleMapController controller = await _controller.future;
              controller.animateCamera(
                  CameraUpdate.newCameraPosition(currentCameraPosition));
              setState(() {
                markers.clear();
                coordinates = LatLng(
                    _currentPosition!.latitude, _currentPosition!.longitude);
                completeAddress = null;
              });
            }
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
