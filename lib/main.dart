import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:pharmacies/home_screen.dart';
import 'package:pharmacies/map_screen.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await dotenv.load(fileName: ".env");

  runApp(GetMaterialApp(
    title: 'Pharamcies',
    theme: ThemeData(primarySwatch: Colors.teal),
    initialRoute: '/home',
    routes: {
      '/home': (context) => const HomeScreen(),
      '/map': (context) => const MapScreen(),
    },
  ));

  FlutterNativeSplash.remove();
}
