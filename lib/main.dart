import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'src/locations.dart' as locations;
import 'package:geolocator/geolocator.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Map<String, Marker> _markers = {};
  static const LatLng sourceLocation = LatLng(27.33500926, -122.03227933);
  static const LatLng destination= LatLng(37.33429383, -122.06600055);
  static const LatLng centerLocation = LatLng(40.03402328491211,116.33757781982422);

  var locationMessage="";
  void getCurrentLocation()async{
    var position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    var lastPosition = await Geolocator.getLastKnownPosition();
    print(lastPosition);
    setState(() {
      locationMessage = "$position.latitude,$position.longitude";
    });
  }
  Future<void> _onMapCreated(GoogleMapController controller) async {
    final googleOffices = await locations.getGoogleOffices();
    var position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    var lastPosition = await Geolocator.getLastKnownPosition();
    setState(() {
      print("setState--------------");
      _markers.clear();
      final marker = Marker(
            markerId: const MarkerId("office.name"),
            position: LatLng(position.latitude, position.longitude),
      );
      _markers['local'] = marker;
      // for (final office in googleOffices.offices) {
      //   final marker = Marker(
      //     markerId: MarkerId(office.name),
      //     position: LatLng(office.lat, office.lng),
      //     infoWindow: InfoWindow(
      //       title: office.name,
      //       snippet: office.address,
      //     ),
      //   );
      //   _markers[office.name] = marker;
      // }
    });
  }
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Google Map Locations'),
          backgroundColor: Colors.green[700],
        ),
        body:
          // Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   crossAxisAlignment: CrossAxisAlignment.center,
          //   children: [
          //     Icon(
          //       Icons.location_on,
          //       size: 46.0,
          //       color: Colors.blue,
          //     ),
          //     SizedBox(height: 10.0,),
          //     Text("Get location",style: TextStyle(fontSize: 26.0,fontWeight: FontWeight.bold),),
          //     SizedBox(
          //       height: 20.0,
          //     ),
          //     Text("press"),
          //   ],
          // )
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: sourceLocation,
              zoom: 2,
            ),
            markers: _markers.values.toSet(),
          ),
      ),
    );
  }
}