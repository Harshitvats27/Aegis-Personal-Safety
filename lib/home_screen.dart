import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shake/shake.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 🔥 Import this
import 'package:women_safety/utils/constants/sizes.dart';
import 'package:women_safety/widgets/home_widgets/custom_appBar.dart';
import 'package:women_safety/widgets/home_widgets/custom_carousel.dart';
import 'package:women_safety/widgets/home_widgets/emergency.dart';
import 'package:women_safety/widgets/home_widgets/live_safe.dart';
import 'package:women_safety/widgets/home_widgets/safehome/SafeHome.dart';
import 'db/db_services.dart';
import 'models/contactsm.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int qIndex = 0;
  Position? _curentPosition;
  String? _curentAddress;
  bool _locationPermissionGranted = false;
  ShakeDetector? _shakeDetector;

  @override
  void initState() {
    super.initState();
    getRandomQuote();
    checkLocationPermission();

    // 🔥 Sirf pehli baar dikhane ka logic
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkFirstTime();
    });
  }

  void checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isAlreadyShown = prefs.getBool('isPrivacyShown');

    if (isAlreadyShown == null || isAlreadyShown == false) {
      showProminentDisclosure(context);
    }
  }

  Future<void> requestAllPermissions() async {
    await Permission.sms.request();
    var locationStatus = await Permission.location.request();
    if (locationStatus.isGranted) {
      await Permission.locationAlways.request();
      _getCurrentLocation();
    }
  }

  void showProminentDisclosure(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.security, color: Colors.blue, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text("Privacy & Safety Notice",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Aegis collects location data to enable real-time tracking during SOS emergency alerts, even when the app is closed."),
                SizedBox(height: 10),
                Text("This is required to keep your guardians updated during an emergency.", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          actions: [
            TextButton(child: Text("Deny"), onPressed: () => Navigator.of(context).pop()),
            ElevatedButton(
              child: Text("Agree & Grant"),
              onPressed: () async {
                Navigator.of(context).pop();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isPrivacyShown', true);
                requestAllPermissions();
              },
            ),
          ],
        );
      },
    );
  }

  checkLocationPermission() async {
    bool permissionGranted = await Permission.location.isGranted;
    setState(() => _locationPermissionGranted = permissionGranted);
  }

  void _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() => _curentPosition = position);
    } catch (e) { print(e); }
  }

  getRandomQuote() {
    Random random = Random();
    setState(() => qIndex = random.nextInt(6));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(USizes.screenPadding),
          child: Column(
            children: [
              CustomAppBar(onTap: getRandomQuote, quoteIndex: qIndex),
              Expanded(
                child: ListView(
                  children: [
                    CustomCarouel(),
                    Text('Emergency', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Emergency(),
                    Text('Explore LiveSafe', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    LiveSafe(),
                    SafeHome(),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}