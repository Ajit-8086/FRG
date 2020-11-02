import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

final String KEY_SAVEVALUE = 'saveornot';
final String KEY_FACEVALUE = 'facesave';
final String KEY_USERNAME = 'username';
final String KEY_LATITUDE = 'latitude';
final String KEY_LONGITUDE = 'longitude';
final String KEY_RADIUS = 'radius';
final String KEY_CHECKINDONE = 'checkindone';

String checkNullandEmpty(String val) {
  if (val == null) {
    return "0";
  } else if (val == "") {
    return "0";
  } else if (val == "null") {
    return "0";
  } else {
    return val;
  }
}

void showToast(BuildContext context, String msg, {int duration, int gravity}) {
  Toast.show(msg, context, duration: duration, gravity: gravity);
}

getSizedBox20() {
  return const SizedBox(
    height: 20,
  );
}
getSizedBox10() {
  return const SizedBox(
    height: 10,
  );
}

getTextWidget(String msg,double font,bool bold){
  return Text(
    msg,
    style: TextStyle(
        fontSize: font, fontWeight: bold?FontWeight.bold:FontWeight.normal),
  );
}

getOutlineButton(String msg,VoidCallback callback){
  return OutlineButton(
      textColor: Colors.blue,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: new Text(
          msg,
          style: TextStyle(fontSize: 16),
        ),
      ),
      onPressed: () {
        // navigateToFaceSetting();
        callback.call();
      },
      shape: new RoundedRectangleBorder(
          borderRadius:
          new BorderRadius.circular(30.0)));
}

getIcon(){
  return const Icon(
    Icons.done,
    color: Colors.green,
    size: 30,
  );
}
