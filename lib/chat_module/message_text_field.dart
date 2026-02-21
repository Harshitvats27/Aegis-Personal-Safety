import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class MessageTextField extends StatefulWidget {
  final String currentId;
  final String friendId;

  const MessageTextField({
    super.key,
    required this.currentId,
    required this.friendId,
  });

  @override
  State<MessageTextField> createState() => _MessageTextFieldState();
}

class _MessageTextFieldState extends State<MessageTextField> {
  final TextEditingController _controller = TextEditingController();

  Position? _currentPosition;
  String? _currentAddress;
  File? imageFile;

  // ================= LOCATION =================

  Future<bool> _handleLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<void> _getCurrentLocation() async {
    bool hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      Fluttertoast.showToast(msg: "Location permission denied");
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks =
    await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark place = placemarks.first;

    setState(() {
      _currentPosition = position;
      _currentAddress =
      "${place.locality ?? ""}, ${place.street ?? ""}, ${place.country ?? ""}";
    });

    Fluttertoast.showToast(msg: "Location fetched");
  }

  // ================= SEND MESSAGE =================

  Future<void> sendMessage(String message, String type) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentId)
        .collection('messages')
        .doc(widget.friendId)
        .collection('chats')
        .add({
      'senderId': widget.currentId,
      'receiverId': widget.friendId,
      'message': message,
      'type': type,
      'date': DateTime.now(),
    });

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.friendId)
        .collection('messages')
        .doc(widget.currentId)
        .collection('chats')
        .add({
      'senderId': widget.currentId,
      'receiverId': widget.friendId,
      'message': message,
      'type': type,
      'date': DateTime.now(),
    });
  }

  // ================= IMAGE =================

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: source);

    if (file == null) return;

    try {
      File image = File(file.path);
      String fileName = const Uuid().v1();

      Reference ref = FirebaseStorage.instance
          .ref()
          .child("images/$fileName.jpg");

      UploadTask uploadTask = ref.putFile(image);

      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();

      await sendMessage(downloadUrl, "img");

    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  // ================= UI =================

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 220,
          child: Column(
            children: [
              const Text(
                "Select Option",
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _iconButton(Icons.location_pin, "Location", () async {
                    Navigator.pop(context);
                    await _getCurrentLocation();

                    if (_currentPosition != null) {
                      String locationMessage =
                          "https://www.google.com/maps/search/?api=1&query=${_currentPosition!.latitude},${_currentPosition!.longitude}\n$_currentAddress";

                      await sendMessage(locationMessage, "link");
                    }
                  }),

                  _iconButton(Icons.camera_alt, "Camera", () async {
                    Navigator.pop(context);
                    await _pickImage(ImageSource.camera);
                  }),

                  _iconButton(Icons.photo, "Gallery", () async {
                    Navigator.pop(context);
                    await _pickImage(ImageSource.gallery);
                  }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _iconButton(
      IconData icon, String title, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.pink,
            child: Icon(icon, color: Colors.white),
          ),
        ),
        const SizedBox(height: 5),
        Text(title),
      ],
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Type your message',
                  filled: true,
                  fillColor: Colors.grey[100],
                  prefixIcon: IconButton(
                    icon: const Icon(Icons.add_box_rounded,
                        color: Colors.pink),
                    onPressed: _showBottomSheet,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send,
                  color: Colors.pink, size: 28),
              onPressed: () async {
                if (_controller.text.isEmpty) return;

                await sendMessage(_controller.text, "text");
                _controller.clear();
              },
            ),
          ],
        ),
      ),
    );
  }
}