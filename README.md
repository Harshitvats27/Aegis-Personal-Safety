# 🛡️ Aegis - Personal Women Safety App

Aegis is a Flutter-based personal safety application designed to provide immediate assistance and real-time tracking during emergencies. Built with a focus on women's safety, it enables users to trigger instant SOS alerts, auto-dial emergency numbers, and share live locations with trusted contacts.
![Women Safety Logo](assets/women_safety_logo.png)

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

## Usage
Use this space to show useful examples of how a project can be used. Additional screenshots, code examples and demos work well in this space. You may also link to more resources



![WhatsApp Image 2025-09-15 at 22 52 56_8fbf716c](https://github.com/user-attachments/assets/e10342d7-6027-48c8-a455-35864ab085ca)

![WhatsApp Image 2025-09-15 at 23 00 05_39cf8dba](https://github.com/user-attachments/assets/c3db83d0-038f-4eaf-8d16-b4133b3f8e5e)
