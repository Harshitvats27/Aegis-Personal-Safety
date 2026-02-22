import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import '../db/db_services.dart';
import '../models/contactsm.dart';

class SOSService {
  static Future<void> triggerSOS() async {
    try {
      await Permission.location.request();
      await Permission.phone.request();

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

      for (var contact in contactList) {
        await FlutterPhoneDirectCaller.callNumber(contact.number);
        await Future.delayed(const Duration(seconds: 20));
      }

      String allNumbers =
      contactList.map((c) => c.number).join(',');

      final Uri smsUri = Uri(
        scheme: 'sms',
        path: allNumbers,
        queryParameters: {'body': message},
      );

      await launchUrl(smsUri);

    } catch (e) {
      print(e);
    }
  }
}