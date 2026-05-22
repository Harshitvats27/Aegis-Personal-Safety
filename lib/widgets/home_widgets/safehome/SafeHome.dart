import 'dart:io'; // 🔥 Android aur iOS separator alag karne ke liye zaroori hai
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
  bool _isLoading = false; // 🔥 Loader state track karne ke liye

  // WhatsApp ke liye number cleanup format fix (Myanmar +95 code bug protection)
  String _formatWhatsAppNumber(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length == 10) {
      cleaned = "91$cleaned"; // India country code automatic prefix
    }
    return cleaned;
  }

  // ================= LOCATION =================

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true; // Loader chalu karo
    });

    try {
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Fluttertoast.showToast(msg: "Location permission denied");
        setState(() {
          _isLoading = false;
        });
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
        _isLoading = false; // Loader band karo
      });

      Fluttertoast.showToast(msg: "Location fetched successfully");
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  // ================= SMS =================

  Future<void> _sendSmsToAll() async {
    if (_currentPosition == null) {
      Fluttertoast.showToast(msg: "Please get location first");
      return;
    }

    List<TContact> contactList = await DatabaseHelper().getContactList();

    if (contactList.isEmpty) {
      Fluttertoast.showToast(msg: "Emergency contact is empty");
      return;
    }

    // 🔥 FIXED MULTI-SMS SEPARATOR: Android me semicolon (;) aur iOS me comma (,) format lagaya h
    String separator = Platform.isAndroid ? ';' : ',';
    String allNumbers = contactList
        .map((e) => e.number.replaceAll(RegExp(r'\D'), ''))
        .join(separator);

    // 🔥 FIXED MAPS LINK INTERPOLATION
    String messageBody =
        "🚨 I am in trouble!\nMy location:\n"
        "https://maps.google.com/?q=${_currentPosition!.latitude},${_currentPosition!.longitude}\n"
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
    String formattedNumber = _formatWhatsAppNumber(phone);

    final Uri whatsappUri = Uri.parse(
        "https://wa.me/$formattedNumber?text=${Uri.encodeComponent(message)}");

    await launchUrl(
      whatsappUri,
      mode: LaunchMode.externalApplication,
    );
  }

  // ================= UI BOTTOM SHEET =================

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder( // StatefulBuilder lagaya taaki sheet ke andar loader live update ho
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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

                        // 🔥 LOADER CONDITIONAL RENDERING FIXED
                        _isLoading
                            ? const Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              CircularProgressIndicator(color: Colors.red),
                              SizedBox(height: 10),
                              Text("Fetching live GPS coordinates...", style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        )
                            : PrimaryButton(
                          title: "📍 STEP 1: GET LOCATION",
                          onPressed: () async {
                            setSheetState(() => _isLoading = true);
                            await _getCurrentLocation();
                            setSheetState(() => _isLoading = false);
                          },
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: _selectContactForWhatsApp,
                          child: const Text("💬 STEP 3: SEND VIA WHATSAPP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      },
    );
  }

  Future<void> _selectContactForWhatsApp() async {
    if (_currentPosition == null) {
      Fluttertoast.showToast(msg: "Please get location first");
      return;
    }

    List<TContact> contactList = await DatabaseHelper().getContactList();

    if (contactList.isEmpty) {
      Fluttertoast.showToast(msg: "Emergency contact is empty");
      return;
    }

    String messageBody =
        "🚨 I am in trouble!\n\n"
        "📍 My Location:\n"
        "https://maps.google.com/?q=${_currentPosition!.latitude},${_currentPosition!.longitude}\n\n"
        "${_currentAddress ?? ""}";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Contact for WhatsApp",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "Choose one emergency contact to send alert",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: contactList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final contact = contactList[index];

                    return InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        Navigator.pop(context);
                        _openWhatsApp(contact.number, messageBody);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.green,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    contact.name ?? "No Name",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(contact.number, style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                            const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green)
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          height: 180,
          width: MediaQuery.of(context).size.width * 0.7,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    ListTile(
                      title: Text("Location ->", style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Share Location"),
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.asset('assets/route.jpg', height: 140, width: 100, fit: BoxFit.cover),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
      ),
    );
  }
}