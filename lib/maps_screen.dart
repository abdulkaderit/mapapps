import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// class MapsScreen extends StatefulWidget {
//   const MapsScreen({super.key});
//
//   @override
//   State<MapsScreen> createState() => _MapsScreenState();
// }
//
// class _MapsScreenState extends State<MapsScreen> {
//   late final GoogleMapController _mapController;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Google Maps'),
//       ),
//       body: GoogleMap(
//           mapType: MapType.terrain,
//           initialCameraPosition: CameraPosition(
//               zoom: 14,
//               target: LatLng(23.80005664936871, 90.35517378038338
//               ),
//           ),
//         zoomControlsEnabled: true,
//         compassEnabled: true,
//         myLocationEnabled: true,
//         myLocationButtonEnabled: true,
//         onMapCreated: (GoogleMapController controller){
//             _mapController = controller;
//         },
//         onTap: (LatLng latLng) {
//           print(latLng);
//         },
//         onLongPress: (LatLng latLng) {
//           print('Long pressed at $latLng');
//         },
//         markers: {
//             Marker(
//               markerId: const MarkerId('my-location'),
//               position: const LatLng(23.80005664936871, 90.35517378038338),
//               icon: BitmapDescriptor.defaultMarkerWithHue(
//                   BitmapDescriptor.hueGreen),
//               onTap: () {
//                 print('Tapped on my marker');
//               },
//               visible: true,
//               infoWindow: InfoWindow(
//                   title: 'My location',
//                   onTap: () {
//                     print('Tapped on info window');
//                   }),
//             ),
//           Marker(
//             markerId: const MarkerId('your-location'),
//             position: const LatLng(23.802028983931763, 90.36494102329016),
//             icon: BitmapDescriptor.defaultMarkerWithHue(
//                 BitmapDescriptor.hueMagenta),
//             onTap: () {
//               print('Tapped on my marker');
//             },
//             visible: true,
//             infoWindow: InfoWindow(
//                 title: 'My location',
//                 onTap: () {
//                   print('Tapped on info window');
//                 }),
//           ),
//           Marker(
//             markerId: const MarkerId('drag-location'),
//             position: const LatLng(23.79297650711677, 90.36178909242153),
//             icon: BitmapDescriptor.defaultMarkerWithHue(
//                 BitmapDescriptor.hueMagenta),
//             onTap: () {
//               print('Tapped on my marker');
//             },
//             visible: true,
//             draggable: true,
//             onDrag: (LatLng latLng) {},
//             onDragStart: (LatLng startedLatLng) {},
//             onDragEnd: (LatLng endLatLng) {
//               print(endLatLng);
//             },
//             infoWindow: InfoWindow(
//                 title: 'My location',
//                 onTap: () {
//                   print('Tapped on info window');
//                 }),
//           ),
//         },
//         // polylines: {
//         //   const Polyline(
//         //       polylineId: PolylineId('StraightLine'),
//         //       width: 8,
//         //       color: Colors.pink,
//         //       endCap: Cap.roundCap,
//         //       startCap: Cap.roundCap,
//         //       points: [
//         //         LatLng(23.827209336849393, 90.3681194409728),
//         //         LatLng(23.787776469936375, 90.36768324673176),
//         //         LatLng(23.808421998041798, 90.35766385495663),
//         //       ],
//         //       jointType: JointType.round)
//         // },
//         circles: {
//           Circle(
//               circleId: const CircleId('virous'),
//               center: const LatLng(23.827559280902364, 90.36343161016703),
//               radius: 500,
//               strokeWidth: 3,
//               strokeColor: Colors.red,
//               fillColor: Colors.red.withOpacity(0.2))
//         },
//         polygons: {
//           Polygon(
//             polygonId: PolygonId('random-polygon'),
//             fillColor: Colors.pink.withOpacity(0.2),
//             strokeWidth: 4,
//             strokeColor: Colors.yellow,
//             points: [
//               LatLng(23.84186232113338, 90.36461982876062),
//               LatLng(23.843746151754996, 90.37738479673862),
//               LatLng(23.82744488211772, 90.37488732486963),
//               LatLng(23.833611231480155, 90.37457551807165),
//               LatLng(23.837750488967334, 90.3654932230711),
//             ],
//           )
//         },
//
//       ),
//       floatingActionButton: FloatingActionButton(
//           child: const Icon(Icons.train),
//           onPressed: (){
//             _mapController.animateCamera(
//                 CameraUpdate.newCameraPosition(
//                     CameraPosition(
//                       zoom: 14,
//                         target: LatLng(23.73812942507436, 90.3954990953207),
//                     ),
//                 )
//             );
//           }
//       ),
//     );
//   }
//   @override
//   void dispose(){
//     _mapController.dispose();
//     super.dispose();
//   }
// }

import 'dart:async';
import 'package:location/location.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  final Location _location = Location();
  GoogleMapController? _mapController;
  LocationData? _currentLocation;
  Marker? _userMarker;
  StreamSubscription<LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    final permissionGranted = await _handleLocationPermission();
    if (!permissionGranted) return;

    final serviceEnabled = await _checkServiceEnabled();
    if (!serviceEnabled) return;

    _currentLocation = await _location.getLocation();
    _updateUserMarker(_currentLocation!);

    // Start listening to live location updates
    _location.changeSettings(accuracy: LocationAccuracy.high, interval: 1000);
    _locationSubscription = _location.onLocationChanged.listen((locationData) {
      setState(() {
        _currentLocation = locationData;
        _updateUserMarker(locationData);
      });

      // Animate the camera
      _mapController?.animateCamera(CameraUpdate.newLatLng(
        LatLng(locationData.latitude!, locationData.longitude!),
      ));
    });
  }

  Future<bool> _handleLocationPermission() async {
    final permission = await _location.hasPermission();
    if (permission == PermissionStatus.granted || permission == PermissionStatus.grantedLimited) {
      return true;
    }

    final request = await _location.requestPermission();
    return request == PermissionStatus.granted || request == PermissionStatus.grantedLimited;
  }

  Future<bool> _checkServiceEnabled() async {
    bool enabled = await _location.serviceEnabled();
    if (!enabled) {
      enabled = await _location.requestService();
    }
    return enabled;
  }

  void _updateUserMarker(LocationData locationData) {
    _userMarker = Marker(
      markerId: const MarkerId('user-location'),
      position: LatLng(locationData.latitude!, locationData.longitude!),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(title: "You're here"),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Maps with GPS')),
      body: _currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          zoom: 16,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (controller) => _mapController = controller,
        markers: {
          if (_userMarker != null) _userMarker!,
          Marker(
            markerId: const MarkerId('static-marker'),
            position: const LatLng(23.802, 90.3649),
            infoWindow: const InfoWindow(title: 'Static Marker'),
          ),
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.my_location),
        onPressed: () async {
          if (_currentLocation != null) {
            _mapController?.animateCamera(CameraUpdate.newLatLng(
              LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
            ));
          }
        },
      ),
    );
  }
}

