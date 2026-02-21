import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shake/shake.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../db/db_services.dart';
import '../../models/contactsm.dart';

class ShakeSOSPage extends StatefulWidget {
  const ShakeSOSPage({super.key});

  @override
  State<ShakeSOSPage> createState() => _ShakeSOSPageState();
}

class _ShakeSOSPageState extends State<ShakeSOSPage> {
  ShakeDetector? _shakeDetector;

  @override
  void initState() {
    super.initState();
    requestPermissions();
    startShakeDetection();
  }

  Future<void> requestPermissions() async {
    await Permission.location.request();
  }

  void startShakeDetection() {
    _shakeDetector = ShakeDetector.autoStart(
      shakeThresholdGravity: 7,
      minimumShakeCount: 1,
      onPhoneShake: () async {
        await triggerSOS();
      },
    );
  }

  Future<void> triggerSOS() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    String locationLink =
        "https://maps.google.com/?q=${position.latitude},${position.longitude}";

    String message =
        "🚨 EMERGENCY!\nI need help.\nMy Live Location:\n$locationLink";

    HapticFeedback.heavyImpact();

    List<TContact> contactList =
    await DatabaseHelper().getContactList();

    if (contactList.isEmpty) return;

    // 📩 Send SMS to all
    String allNumbers =
    contactList.map((c) => c.number).join(',');

    final Uri smsUri = Uri(
      scheme: 'sms',
      path: allNumbers,
      queryParameters: {'body': message},
    );

    await launchUrl(smsUri);

    // 📞 Auto call first contact
    for (var contact in contactList) {
      await FlutterPhoneDirectCaller.callNumber(contact.number);
      await Future.delayed(const Duration(seconds: 30));
    }

  }

  @override
  void dispose() {
    _shakeDetector?.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Shake Phone to Send SOS 🚨",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}