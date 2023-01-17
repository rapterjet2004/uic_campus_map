import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:uic_map/pages/main_map.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() {
  runApp(const MyApp());
  initFireBase();
}

void initFireBase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

  }

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  final Color primaryColor = const Color.fromARGB(255, 212, 31, 52);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: primaryColor,
        splashColor: primaryColor,
        highlightColor: primaryColor,
        colorScheme: ColorScheme.light(secondary: primaryColor)
      ),
      home: MainMapPage(),
    );
  }

}

