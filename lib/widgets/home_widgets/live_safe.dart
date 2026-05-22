
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import 'live_safe/BusStationCard.dart';
import 'live_safe/HospitalCard.dart';
import 'live_safe/PharmacyCard.dart';
import 'live_safe/PoliceStationCard.dart';

class LiveSafe extends StatelessWidget {
  const LiveSafe({super.key});

  static Future<void> openMap(String location) async {
    final String encodedLocation = Uri.encodeComponent(location);
    final Uri url = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$encodedLocation");

    try {
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception("Could not launch $url");
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: 'Something went wrong! Call emergency number');
    }
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      width: MediaQuery.of(context).size.width,
      child: ListView(
        physics: BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: [
          PoliceStationCard(onMapFunction: openMap),
          HospitalCard(onMapFunction: openMap),
          PharmacyCard(onMapFunction: openMap),
          BusStationCard(onMapFunction: openMap),
        ],
      ),
    );
  }
}