import 'package:Face_recognition/info/app_use.dart';
import 'package:Face_recognition/info/common.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LocationPageState();
}

class LocationPageState extends State<LocationPage> {
  GoogleMapController mapController;

  LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  LocationData _locationData;

  getCurrentLat() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    _center = LatLng(_locationData.latitude, _locationData.longitude);
    selectedLat = _locationData.latitude;
    selectedLon = _locationData.longitude;
    lst.add(Marker(
        markerId: MarkerId('154'),
        position: LatLng(
          _locationData.latitude,
          _locationData.longitude,
        )));
    return true;
  }

  Set<Marker> lst = Set();

  Future getMap;

  @override
  void initState() {
    _controllerRadius = TextEditingController(text: '100');
    getMap = getCurrentLat();
    super.initState();
  }

  double selectedLat = 0;
  double selectedLon = 0;

  TextEditingController _controllerRadius;

  @override
  void dispose() {
    _controllerRadius.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: getMap,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    // decoration: BoxDecoration(
                    //     border: Border.all(color: Colors.blueAccent, width: 2)),
                    child: Stack(
                      alignment: AlignmentDirectional.topCenter,
                      children: [
                        GoogleMap(
                          onMapCreated: _onMapCreated,
                          compassEnabled: true,
                          buildingsEnabled: true,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          onTap: (LatLng latLng) {
                            print('_locationData.latitude' +
                                latLng.latitude.toString());
                            print('_locationData.longitude' +
                                latLng.longitude.toString());
                            setState(() {
                              _center =
                                  LatLng(latLng.latitude, latLng.longitude);
                              lst.clear();
                              lst.add(Marker(
                                  markerId: MarkerId('154'),
                                  position: LatLng(
                                    latLng.latitude,
                                    latLng.longitude,
                                  )));
                              selectedLat = latLng.latitude;
                              selectedLon = latLng.longitude;
                            });
                          },
                          markers: lst,
                          initialCameraPosition: CameraPosition(
                            target: _center,
                            zoom: 17.0,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            // color: Colors.black54,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black54,
                                ),
                                color: Colors.black54,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20))),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                "Tap on any location to set as default latlon",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xffedeae9),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 2,
                      child: Column(
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(20),
                              child: TextField(
                                keyboardType: TextInputType.number,
                                maxLength: 4,
                                controller: _controllerRadius,
                                decoration: new InputDecoration(
                                    border: new OutlineInputBorder(
                                        borderSide:
                                            new BorderSide(color: Colors.teal)),
                                    hintText: 'Enter radius for validation',
                                    helperText:
                                        '*Max allowed geofence distance.',
                                    labelText: 'Geofence Radius',
                                    prefixIcon: const Icon(
                                      Icons.eighteen_mp,
                                      color: Colors.green,
                                    ),
                                    prefixText: ' ',
                                    suffixText: 'Meter',
                                    suffixStyle:
                                        const TextStyle(color: Colors.green)),
                              )),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Latitude    :" + selectedLat.toString(),
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    "Longitude :" + selectedLon.toString(),
                                    style: TextStyle(fontSize: 16),
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          OutlineButton(
                              textColor: Colors.blue,
                              autofocus: true,
                              color: Colors.blue,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: new Text(
                                  "     Save     ",
                                  style: TextStyle(fontSize: 25),
                                ),
                              ),
                              onPressed: () {
                                if (_controllerRadius.text.isEmpty) {
                                } else {
                                  saveLatLon();
                                }
                              },
                              shape: new RoundedRectangleBorder(
                                  borderRadius:
                                      new BorderRadius.circular(30.0)))
                        ],
                      ),
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  void saveLatLon() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(KEY_LATITUDE, selectedLat);
    await prefs.setDouble(KEY_LONGITUDE, selectedLon);
    await prefs.setInt(KEY_RADIUS, int.parse(_controllerRadius.text));
    await prefs.setInt(KEY_SAVEVALUE, 1);
    Navigator.pop(context);
  }
}
