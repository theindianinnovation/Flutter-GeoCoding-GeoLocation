import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Geolocator geolocator = Geolocator();
  Position? userLocation;
  double? distanceInMeters;
  String? currentAddress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Geolocator Plugin"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  onPressed: () {
                    _getLocation().then((value) {
                      setState(() {
                        userLocation = value;
                      });
                    });
                  },
                  color: Colors.blue,
                  child: Text(
                    "Get Location",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Center(child: Text(userLocation.toString())),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RaisedButton(
                  onPressed: () {
                    setState(() {
                      distanceInMeters = Geolocator.distanceBetween(
                          52.2165957, 6.9437819, 52.3546274, 4.8285838);
                    });
                  },
                  color: Colors.black,
                  child: Text(
                    "Get Distance In Meters",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              Center(child: Text(distanceInMeters.toString())),
              RaisedButton(
                color: Colors.red,
                onPressed: () async {
                  await Geolocator.openAppSettings();
                  //await Geolocator.openLocationSettings();
                },
                child: Text("Open App Settings"),
              ),
              RaisedButton(
                color: Colors.green,
                onPressed: () async {
                  await Geolocator.openLocationSettings();
                },
                child: Text("Open Location Settings"),
              ),

              RaisedButton(
                child: Text("Get Adress From Co-Ordinates"),
                onPressed: () {
                 getAddressFromLatLng();
                },
              ),
              if (currentAddress != null) Text(
                  currentAddress!
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Position> _getLocation() async {
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
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await  placemarkFromCoordinates(
          52.2165157, 6.9437819);

      Placemark place = placemarks[0];

      setState(() {
        currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }
}
