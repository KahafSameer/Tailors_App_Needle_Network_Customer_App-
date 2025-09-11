// ignore_for_file: file_names, unused_element, non_constant_identifier_names, unused_local_variable
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:needle_network_main/Data_Provider.dart';
import 'package:needle_network_main/MainApp/TailorInfoPage.dart';
import 'package:needle_network_main/ModalClasses/TailorsData.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TailorsMap extends StatefulWidget {
  const TailorsMap({Key? key}) : super(key: key);

  @override
  State<TailorsMap> createState() => _TailorsMapState();
}

class _TailorsMapState extends State<TailorsMap> {
  Set<Marker> markers = {};
  Position? _currentPosition;
  late CameraPosition currentLocation;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initMap();
  }

  Future<void> _initMap() async {
    await _getCurrentLocation();
    await _fetchTailorLocations();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
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
        currentLocation = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          tilt: 59.44,
          zoom: 15,
        );
        // Remove previous user marker if exists
        markers.removeWhere((m) => m.markerId.value == 'user_location');
        // Add user marker
        markers.add(
          Marker(
            markerId: const MarkerId('user_location'),
            position: LatLng(position.latitude, position.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure),
            infoWindow: const InfoWindow(title: "You are here"),
          ),
        );
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Could not get location.');
    }
  }

  Future<void> _fetchTailorLocations() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('Business Info').get();
      for (DocumentSnapshot doc in snapshot.docs) {
        TailorsData tailorsData = TailorsData(
          shopImage: doc['Shop Image'],
          shopName: doc['Shop Name'],
          address: doc['Address'],
          longitude: doc['Longitude'],
          latitude: doc['Latitude'],
          location: doc['Location'],
          phoneNumber: doc['Phone Number'],
          aboutBusiness: doc['About Business'],
          openingTime: doc['Opening Time'],
          closingTime: doc['Closing Time'],
          open24Hours: doc['Open 24 Hours'],
          lahenga: doc['Lahega'],
          sherwani: doc['Sherwani'],
          suits: doc['Suits'],
          waistCoat: doc['WaistCoat'],
          uniforms: doc['Uniforms'],
          pantCoat: doc['Pant Coat'],
          men: doc['Men'],
          women: doc['Women'],
          children: doc['Children'],
          elders: doc['Elders'],
          docId: doc.id,
        );
        double latitude = doc['Latitude'];
        double longitude = doc['Longitude'];
        String shopName = doc['Shop Name'];
        String description = doc['About Business'];
        LatLng location = LatLng(latitude, longitude);

        markers.add(
          Marker(
            markerId: MarkerId('${location.latitude}${location.longitude}'),
            position: location,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            onTap: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(shopName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20)),
                        const SizedBox(height: 8),
                        Text(description, style: const TextStyle(fontSize: 15)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TailorInfoPage(
                                        tailorsData: tailorsData),
                                  ),
                                );
                              },
                              child: const Text('Visit'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Could not load tailors.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || _currentPosition == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
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
          title: const Text(
            'Find Tailors',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
              fontSize: 22,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.blue),
              tooltip: "Refresh",
              onPressed: () async {
                setState(() {
                  isLoading = true;
                  markers.clear();
                });
                await _initMap();
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: currentLocation,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              markers: markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'tailorsmap_fab',
          backgroundColor: Colors.blue,
          tooltip: "Go to my location",
          onPressed: () async {
            await _getCurrentLocation();
            if (_currentPosition != null) {
              final GoogleMapController controller = await _controller.future;
              controller.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: LatLng(_currentPosition!.latitude,
                        _currentPosition!.longitude),
                    tilt: 59.44,
                    zoom: 15,
                  ),
                ),
              );
            }
          },
          child: const Icon(Icons.gps_fixed),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
