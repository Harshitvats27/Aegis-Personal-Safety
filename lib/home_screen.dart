import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shake/shake.dart';
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
  // const HomeScreen({super.key});
  int qIndex = 0;
  Position? _curentPosition;
  String? _curentAddress;
  LocationPermission? permission;

  _getPermission() async => await [Permission.sms].request();

  _isPermissionGranted() async => await Permission.sms.status.isGranted;

  // _sendSms(String phoneNumber, String message, {int? simSlot}) async {
  //   SmsStatus result = await BackgroundSms.sendMessage(
  //       phoneNumber: phoneNumber, message: message, simSlot: 1);
  //   if (result == SmsStatus.sent) {
  //     print("Sent");
  //     Fluttertoast.showToast(msg: "send");
  //   } else {
  //     Fluttertoast.showToast(msg: "failed");
  //   }
  // }
  String _currentCity = "";

  checkLocationPermission() async {
    bool permissionGranted = await _requestLocationPermission();
    setState(() {
      _locationPermissionGranted = permissionGranted;
    });

    if (_locationPermissionGranted) {
      _getCurrentCity();
    }
  }

  void _getCurrentCity() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        setState(() {
          _currentCity = placemark.locality ?? 'Unknown';
        });
        print(_currentCity);
      }
    } catch (e) {
      print('Error getting current city: $e');
    }
  }

  bool _locationPermissionGranted = false;

  Future<bool> _requestLocationPermission() async {
    var status = await Permission.location.request();
    return status == PermissionStatus.granted;
  }

  void _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print('Current Location: $position');
      _getCurrentAddress();
      // Handle the obtained location as needed
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  String currentCity = '';

  _getCurrentAddress() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _curentPosition!.latitude, _curentPosition!.longitude);

      Placemark place = placemarks[0];
      setState(() {
        _curentAddress =
        "${place.locality},${place.postalCode},${place.street},";
        print(_curentAddress);
      });
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }


  getRandomQuote() {
    Random random = Random();
    setState(() {
      qIndex = random.nextInt(6);
    });
  }
 ShakeDetector? _shakeDetector;

  @override
  void initState() {
    super.initState();

  }
  @override
  void dispose() {
    // 🔥 Safe Check: Agar initialize hua hoga, tabhi stop hoga, koi crash nahi aayega!
    if (_shakeDetector != null) {
      _shakeDetector!.stopListening(); // ya .stop() jo bhi aapki library support kare
    }
    super.dispose();
  }
  getAndSendSms() async {
    List<TContact> contactList = await DatabaseHelper().getContactList();

    String messageBody =
        "https://maps.google.com/?daddr=${_curentPosition!
        .latitude},${_curentPosition!.longitude}";
    if (await _isPermissionGranted()) {
      for (var element in contactList) {
        // _sendSms("${element.number}", "i am in trouble $messageBody");
      }
    } else {
      Fluttertoast.showToast(msg: "something wrong");
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(USizes.screenPadding),
          child: Column(
            children: [
              CustomAppBar(
                onTap: getRandomQuote,
                quoteIndex: qIndex,
              ),
              SizedBox(height: USizes.spaceBtwSections,),
              Expanded(child: ListView(
                shrinkWrap: true,
                children: [
                  CustomCarouel(),
                  SizedBox(height: USizes.spaceBtwSections,),
                  Text('Emergency', style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),),
                  SizedBox(height: USizes.spaceBtwSections,),
                  Emergency(),
                  SizedBox(height: USizes.spaceBtwSections,),
                  Text('Explore LiveSafe', style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),),
                  SizedBox(height: USizes.spaceBtwSections,),
                  LiveSafe(),
                  SizedBox(height: USizes.spaceBtwItems),
                  SafeHome(),
                ],
              ))

            ],
          ),
        ),
      ),
    );
  }
}
