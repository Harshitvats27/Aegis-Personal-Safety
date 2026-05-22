import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:women_safety/widgets/components/PrimaryButton.dart';

import '../../../db/db_services.dart';
import '../../../models/contactsm.dart';

class SafeHome extends StatefulWidget {
  const SafeHome({super.key});

  @override
  State<SafeHome> createState() => _SafeHomeState();
}

class _SafeHomeState extends State<SafeHome> {
  Position? _currentPosition;
  String? _currentAddress;

  // ================= LOCATION =================

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(msg: "Location permission denied");
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, position.longitude);

    Placemark place = placemarks.first;

    setState(() {
      _currentPosition = position;
      _currentAddress =
      "${place.locality ?? ""}, ${place.street ?? ""}, ${place.country ?? ""}";
    });

    Fluttertoast.showToast(msg: "Location fetched successfully");
  }

  // ================= SMS =================

  Future<void> _sendSmsToAll() async {
    if (_currentPosition == null) {
      Fluttertoast.showToast(msg: "Please get location first");
      return;
    }

    List<TContact> contactList =
    await DatabaseHelper().getContactList();

    if (contactList.isEmpty) {
      Fluttertoast.showToast(msg: "Emergency contact is empty");
      return;
    }

    // Clean numbers + join
    String allNumbers = contactList
        .map((e) => e.number.replaceAll(RegExp(r'\D'), ''))
        .join(',');

    String messageBody =
        "🚨 I am in trouble!\nMy location:\n"
        "https://www.google.com/maps/search/?api=1&query=${_currentPosition!.latitude},${_currentPosition!.longitude}\n"
        "${_currentAddress ?? ""}";

    final Uri smsUri = Uri.parse(
        "sms:$allNumbers?body=${Uri.encodeComponent(messageBody)}");

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      Fluttertoast.showToast(msg: "Could not open SMS app");
    }
  }

  // ================= WHATSAPP =================

  Future<void> _openWhatsApp(String phone, String message) async {
    String formattedNumber = phone.replaceAll(RegExp(r'\D'), '');

    final Uri whatsappUri = Uri.parse(
        "https://wa.me/$formattedNumber?text=${Uri.encodeComponent(message)}");

    await launchUrl(
      whatsappUri,
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _sendWhatsAppToAll() async {
    if (_currentPosition == null) {
      Fluttertoast.showToast(msg: "Please get location first");
      return;
    }

    List<TContact> contactList =
    await DatabaseHelper().getContactList();

    if (contactList.isEmpty) {
      Fluttertoast.showToast(msg: "Emergency contact is empty");
      return;
    }

    String messageBody =
        "🚨 I am in trouble!\nMy location:\n"
        "https://www.google.com/maps/search/?api=1&query=${_currentPosition!.latitude},${_currentPosition!.longitude}\n"
        "${_currentAddress ?? ""}";

    for (var element in contactList) {
      await _openWhatsApp(element.number, messageBody);
    }
  }

  // ================= UI =================

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // ⭐ IMPORTANT
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // ⭐ IMPORTANT
                  children: [

                    const Text(
                      "🚨 EMERGENCY ALERT",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),

                    const SizedBox(height: 20),

                    PrimaryButton(
                      title: "📍 STEP 1: GET LOCATION",
                      onPressed: _getCurrentLocation,
                    ),

                    const SizedBox(height: 15),

                    PrimaryButton(
                      title: "📩 STEP 2: SEND VIA SMS",
                      onPressed: _sendSmsToAll,
                    ),

                    const SizedBox(height: 15),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: _selectContactForWhatsApp,
                      child: const Text("💬 STEP 3: SEND VIA WHATSAPP"),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  Future<void> _selectContactForWhatsApp() async {
    if (_currentPosition == null) {
      Fluttertoast.showToast(msg: "Please get location first");
      return;
    }

    List<TContact> contactList =
    await DatabaseHelper().getContactList();

    if (contactList.isEmpty) {
      Fluttertoast.showToast(msg: "Emergency contact is empty");
      return;
    }

    String messageBody =
        "🚨 I am in trouble!\n\n"
        "📍 My Location:\n"
        "https://www.google.com/maps/search/?api=1&query="
        "${_currentPosition!.latitude},${_currentPosition!.longitude}\n\n"
        "${_currentAddress ?? ""}";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 🔥 Header
              const Text(
                "Select Contact for WhatsApp",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Choose one emergency contact to send alert",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 20),

              // 📱 Contact List
              Expanded(
                child: ListView.separated(
                  itemCount: contactList.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final contact = contactList[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        Navigator.pop(context);
                        _openWhatsApp(
                          contact.number,
                          messageBody,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius:
                          BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.green.shade200,
                          ),
                        ),
                        child: Row(
                          children: [

                            const CircleAvatar(
                              backgroundColor: Colors.green,
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(width: 15),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    contact.name ??
                                        "No Name",
                                    style: const TextStyle(
                                      fontWeight:
                                      FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    contact.number,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            FaIcon(
                              FontAwesomeIcons.whatsapp,
                              color: Colors.green,
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _showBottomSheet,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SizedBox(
          height: 180,
          width: MediaQuery.of(context).size.width * 0.7,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: const [
                    ListTile(
                      title: Text("Location->"),
                      subtitle: Text("Share Location"),
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.asset('assets/route.jpg'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}