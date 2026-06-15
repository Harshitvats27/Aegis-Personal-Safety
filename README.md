# 🛡️ Aegis - Personal Women Safety App

Aegis is a Flutter-based personal safety application designed to provide immediate assistance and real-time tracking during emergencies. Built with a focus on women's safety, it enables users to trigger instant SOS alerts, auto-dial emergency numbers, and share live locations with trusted contacts.
![WhatsApp Image 2025-09-15 at 21 32 57_2fc82fd7](https://github.com/user-attachments/assets/fb0b81b3-4d93-4c44-b4fa-f6cfe4b48ca0)

## ✨ Key Features

* **📱 Shake to Trigger SOS**: Simply shake the device to activate the emergency protocol without unlocking the phone.
* **📍 Live Location Sharing**: Automatically fetches high-accuracy GPS coordinates and generates a Google Maps tracking link.
* **💬 Automated SOS Broadcast**: Instantly sends emergency SMS with the live location link to all pre-saved trusted contacts.
* **📞 Smart Auto-Call Rotator**: Automatically dials the primary emergency contact. If unanswered, it intelligently rotates and dials the next trusted contact every 15 seconds.
* **🏥 Nearest Safe Zones**: One-tap access to find the nearest:
  * Police Stations
  * Hospitals & Pharmacies
  * Bus Stands
* **🆘 Quick Emergency Dials**: Direct one-tap calling to Indian National Emergency services (Police 112, Ambulance 102, Fire 101, Women Helpline 1091).
* **📚 Safety Resources**: In-app web views for reading articles on women's rights, self-defense techniques, and inspiring stories.
* **📇 Trusted Contacts Management**: Easily add, view, and delete emergency contacts using a local SQLite database.

## 🛠️ Tech Stack

* **Framework:** Flutter (Dart)
* **Local Database:** SQLite (sqflite)
* **Location Services:** geolocator, geocoding
* **Hardware Sensors:** shake (Shake detection)
* **Telephony & SMS:** flutter_phone_direct_caller, url_launcher
* **Permissions:** permission_handler
* **State Management:** `setState` / Flutter built-in

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (Latest stable version)
* Android Studio / VS Code
* An Android Device or Emulator (Physical device recommended for testing calls, SMS, and Shake sensors).
