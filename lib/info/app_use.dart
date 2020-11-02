import 'package:Face_recognition/face/face_setting.dart';
import 'package:Face_recognition/info/common.dart';
import 'package:Face_recognition/location/location_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import 'common.dart';

class AppUse extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AppUseState();
}

class AppUseState extends State<AppUse> {
  bool checkIn = true;
  int checkInDone = -1;

  isDataSet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (null == prefs.getInt(KEY_FACEVALUE)) {
      faceSaved = 0;
    } else {
      faceSaved = prefs.getInt(KEY_FACEVALUE);
    }
    if (null == prefs.getInt(KEY_SAVEVALUE)) {
      valueSet = 0;
    } else {
      valueSet = prefs.getInt(KEY_SAVEVALUE);
    }
    return valueSet;
  }

  Future checkData;

  @override
  void initState() {
    checkData = isDataSet();
    checkInDone = -1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: checkData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.all(15),
                child: Container(
                    constraints: const BoxConstraints.expand(),
                    child: Column(
                      children: [
                        getSizedBox20(),
                        getTextWidget('Face Recongition-Geofencing', 25, true),
                        getSizedBox20(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            getTextWidget(
                                '1.Save a face for further recognition',
                                16,
                                false),
                            getSizedBox20(),
                            Row(
                              children: [
                                getOutlineButton("Capture face", () {
                                  navigateToFaceSetting();
                                }),
                                faceSaved == 1 ? getIcon() : Container(),
                              ],
                            ),
                            getSizedBox20(),
                            getTextWidget(
                                '2.Define lat long for and radius for geofencing',
                                16,
                                false),
                            getSizedBox20(),
                            Row(
                              children: [
                                getOutlineButton("Location and Distance", () {
                                  navigateToLocationSetting();
                                }),
                                valueSet == 1 ? getIcon() : Container(),
                              ],
                            ),
                            getSizedBox20(),
                            getTextWidget(
                                '3.Use Check-In/Check-Out icon ', 16, false),
                            getSizedBox20(),
                          ],
                        ),

                        getSizedBox20(),
                        GestureDetector(
                          onTap: () {
                            if (faceSaved != 1) {
                              showToast(context, "Capture face first",
                                  gravity: Toast.CENTER);
                            } else if (valueSet != 1) {
                              showToast(context, "Set up location and radius");
                            } else {
                              navigateToFaceDetect();
                            }
                          },
                          child: Column(
                            children: [
                              Container(
                                  decoration: new BoxDecoration(
                                    borderRadius:
                                        new BorderRadius.circular(100.0),
                                    border: new Border.all(
                                      width: 1.0,
                                      color: Colors.red,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Image.asset(
                                      'assets/location.png',
                                      height: 100,
                                      width: 100,
                                    ),
                                  )),
                              SizedBox(
                                height: 5,
                              ),
                              getTextWidget(checkIn ? 'Check-In' : 'Check-Out',
                                  20, false),
                              getSizedBox10(),
                              CheckInOutSucc
                                  ? Text(
                                      checkInDone == 0
                                          ? 'Check in Successful'
                                          : checkInDone == 1
                                              ? 'Check out Successful'
                                              : "",
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.green),
                                    )
                                  : Text(
                                      checkInDone == 0
                                          ? 'Check out failed'
                                          : checkInDone == 1
                                              ? 'Check in failed'
                                              : "",
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.red),
                                    ),
                              getSizedBox10(),
                              faceMsg == 0
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        getTextWidget(
                                            'Distance found from defined location is:',
                                            15,
                                            false),
                                        getTextWidget(
                                            _distanceInMeters
                                                    .toStringAsFixed(2) +
                                                " M",
                                            15,
                                            true),
                                      ],
                                    )
                                  : faceMsg == 1
                                      ? Text(
                                          '*Face is not matching with saved face!',
                                          style: TextStyle(
                                              fontSize: 15, color: Colors.red),
                                        )
                                      : Container(),
                            ],
                          ),
                        )
                        // Icon(Icons.edit_location,size: 60,color: Colors.red,)
                      ],
                    )),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  onGoBack(dynamic value) {
    setState(() {
      valueSet = 1;
    });
  }

  onFaceSaved(dynamic value) {
    setState(() {
      faceSaved = 1;
    });
  }

  int valueSet = 0;
  int faceSaved = 0;

  LocationData _locationData;
  double _distanceInMeters = 0;

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('Saved lat' + prefs.getDouble(KEY_LATITUDE).toString());
    print('Saved lat' + prefs.getDouble(KEY_LONGITUDE).toString());
    _distanceInMeters = await Geolocator.distanceBetween(
      _locationData.latitude,
      _locationData.longitude,
      prefs.getDouble(KEY_LATITUDE),
      prefs.getDouble(KEY_LONGITUDE),
    );

    print('dist found' + _distanceInMeters.toString());
    int definedRadius = prefs.getInt(KEY_RADIUS);
    print('radius defined' + definedRadius.toString());
    faceMsg = 0;
    if (definedRadius >= _distanceInMeters) {
      print('CheckIn Success');
      CheckInOutSucc = true;
    } else {
      print('distace is more than defined');
      // checkInDone = -1;
      CheckInOutSucc = false;
    }
    if (checkIn) {
      checkInDone = 0;
      checkIn = false;
    } else {
      checkInDone = 1;
      checkIn = true;
    }
    setState(() {});
  }

  void navigateToLocationSetting() {
    Route route = MaterialPageRoute(builder: (context) => LocationPage());
    Navigator.push(context, route).then(onGoBack);
  }

  void navigateToFaceSetting() {
    Route route = MaterialPageRoute(
        builder: (context) => FaceSetting(false, (bool faceMatched) {}));
    Navigator.push(context, route).then(onFaceSaved);
  }

  int faceMsg = -1;
  bool CheckInOutSucc = false;

  void navigateToFaceDetect() {
    Route route = MaterialPageRoute(
        builder: (context) => FaceSetting(true, (bool faceMatched) {
              print('faceMatched' + faceMatched.toString());
              if (faceMatched) {
                getCurrentLat();
              } else {
                CheckInOutSucc = false;
                faceMsg = 1;
                checkInDone = -1;
                setState(() {});
              }
            }));
    Navigator.push(context, route).then(onFaceSaved);
  }
}

typedef onFaceDetected = void Function(bool faceMatched);
