import 'dart:io'; // Android unique format identifier check karne ke liye
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
      // User ko instantly register ka feedback mile
      HapticFeedback.heavyImpact();

      // 1. Database se contacts nikalenge (Ultra Fast)
      List<TContact> contactList = await DatabaseHelper().getContactList();
      if (contactList.isEmpty) {
        Fluttertoast.showToast(msg: "No trusted contacts found!");
        return;
      }

      // =======================================================
      // ⚡ 🔥 STEP 1: PEHLE CALLS IN BACKGROUND (NON-BLOCKING)
      // =======================================================
      // Loop ke aage se aur callNumber ke aage se await ko process thread bypass me daal diya h.
      // Is se pehli call instantly trigger ho jayegi aur code aage badh jayega!
      Future.delayed(Duration.zero, () async {
        for (var contact in contactList) {
          String cleanNumber = contact.number.replaceAll(RegExp(r'\s+'), "");
          // No blocking await here, background processing mode
          FlutterPhoneDirectCaller.callNumber(cleanNumber);

          // Agli call ke liye 5 second ka wait loop back chalega
          await Future.delayed(const Duration(seconds: 30));
        }
      });

      // =======================================================
      // 📍 STEP 2: MULTI-SMS BROADCAST (ALL CONTACTS TOGETHER)
      // =======================================================
      // Calls chalu hote hi niche wala message process bina ruke execute hoga
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium, // High se fast coordinate nikalta h
      );

      // 🔥 MAPS LINK FIXED: Aapki interpolation syntax galti ko yahan fix kiya h:
      // 🔥 MAPS LINK FIXED: Universal Google Maps Format with proper interpolation
      String locationLink =
          "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";

      String message =
          "🚨 EMERGENCY!\nI need help. Track my live location here:\n$locationLink";
      // Android me semicolon (;) aur iOS me comma (,) format check setup kiya h
      String separator = Platform.isAndroid ? ';' : ',';
      String allNumbers = contactList.map((c) => c.number.replaceAll(RegExp(r'\s+'), "")).join(separator);

      final Uri smsUri = Uri(
        scheme: 'sms',
        path: allNumbers,
        queryParameters: {'body': message},
      );

      // SMS panel saare contacts ke numbers ko ek sath jod kar pop up kar dega
      await launchUrl(smsUri, mode: LaunchMode.externalApplication);

    } catch (e) {
      print("❌ SOS Execution Error: $e");
    }
  }
}