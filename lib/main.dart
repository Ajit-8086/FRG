
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'info/app_use.dart';

void main() {
  runApp(MaterialApp(
    themeMode: ThemeMode.light,
    theme: ThemeData(brightness: Brightness.light,accentColor: Colors.amber),
    home: AppUse(),
    title: "Face Recognition",
    debugShowCheckedModeBanner: false,
  ));
}


