# HAUPokemon 🎮📍

[![Flutter](https://img.shields.io/badge/Flutter-Framework-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-Language-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)](https://developer.android.com/)
[![AWS EC2](https://img.shields.io/badge/Cloud-AWS%20EC2-FF9900?logo=amazonec2&logoColor=white)](https://aws.amazon.com/ec2/)
[![OpenStreetMap](https://img.shields.io/badge/Maps-OpenStreetMap-7EBC6F?logo=openstreetmap&logoColor=white)](https://www.openstreetmap.org/)
[![REST API](https://img.shields.io/badge/API-HTTP%20%2F%20JSON-4B8BBE)](https://www.json.org/json-en.html)
[![Academic Project](https://img.shields.io/badge/Project-Academic-6A737D)](#academic-project)
[![Made with AI](https://img.shields.io/badge/Made_with-AI_assistance-blue)](#ai-credits)

HAUPokemon is a location-based monster-catching mobile application developed as a **group school project** for a cloud-computing course (6CloudCom). Built with Flutter, it combines GPS-based gameplay with a backend API and AWS EC2 status and control features.

> **Project context:** Academic group project. My contributions focused on Flutter application work, AWS EC2 setup, and bug fixing. The features listed below describe the project as a whole, not necessarily work completed individually by me.

## Features

- **Player accounts:** register, log in, and log out.
- **Monster collection:** view the monster list, with create, update, and delete operations.
- **Location-based detection:** use device location to check for nearby monsters and their distance.
- **Interactive monster map:** view monster spawn locations and their spawn-radius circles using OpenStreetMap.
- **Catching feedback:** trigger sound and flashlight feedback when a monster is detected, where the device supports it.
- **Leaderboard:** view the top players.
- **Cloud instance status and controls:** display EC2 instance status and send start/stop requests through the configured API.

## My Contributions

As a member of the project team, my work included:

- Contributing to the Flutter application.
- Helping set up and configure AWS EC2 for the project.
- Debugging issues and helping fix application problems.

This is a summary of my individual contributions; the application was built collaboratively with my teammates.

## Tech Stack

| Area | Technologies |
|---|---|
| Mobile app | Flutter, Dart |
| API communication | HTTP, JSON |
| Location and maps | Geolocator, Flutter Map, OpenStreetMap, LatLong2 |
| State and local preferences | Provider, Shared Preferences |
| Media and device features | AudioPlayers, Torch Light, Image Picker, Permission Handler, Cached Network Image |
| Cloud infrastructure | AWS EC2; API endpoints are configured separately |
| Code quality | Flutter Lints |

## How It Works

1. A player registers or logs in.
2. The app requests location permission when the player uses location-based detection.
3. The app sends authenticated requests to the configured backend to retrieve monsters and check for nearby spawns.
4. The map screen displays monster locations using OpenStreetMap-based map components.
5. The EC2 screen queries the configured cloud API for instance status and sends control requests.

## Project Structure

```
lib/
├── main.dart
├── config/       # API and AWS endpoint configuration
├── models/       # Monster
├── services/     # Auth and monster API clients
└── screens/      # Login, register, home, map, catch, monsters, leaderboard, EC2 control, about
assets/sounds/    # Alert sound
```

## Run Locally

### Requirements

- Flutter SDK compatible with the Dart SDK range in `pubspec.yaml`
- Android Studio, VS Code, or another Flutter-supported development environment
- A compatible backend/API. **The backend is not included in this repository.**
- A physical Android device is recommended, since GPS and flashlight features need real hardware

### Setup

1. Clone the repository and install dependencies:

   ```bash
   git clone https://github.com/rnzcrt/hau_pokemon_app.git
   cd hau_pokemon_app
   flutter pub get
   ```

2. Set the API endpoints in `lib/config/app_config.dart` (`baseUrl`, and the EC2 status and control URLs) to an environment you are authorized to use.

   **Security:** do not commit private URLs, server addresses, access tokens, or passwords to a public repository.

3. Run the app:

   ```bash
   flutter run
   ```

> The app will not fully work until its backend/API endpoints are configured and reachable. Some services may need a VPN or specific network setup.

## Limitations and Notes

- Location-based features depend on device permissions and location services.
- Backend-dependent features require the configured API to be available.
- Flashlight feedback depends on device hardware and platform permissions.
- The EC2 start/stop controls should only be used in the intended project environment by authorized users.

## Academic Project

Developed collaboratively as a school project at **Holy Angel University**.

This repository reflects my experience contributing to a Flutter application, working with cloud infrastructure, integrating API-driven functionality, and debugging issues in a team project.

## Team

Group project at Holy Angel University.

- [Ranz Emmanuel Cuarto](https://github.com/rnzcrt)
- [Mark Darius David](https://github.com/darsy29)
- [Rian Cortez](https://github.com/riancrtz)
- [Ryence Cortez](https://github.com/Ryence07)
- [Jeremiah Carbungco](https://github.com/JerJers)

## AI Credits

AI tools were used to help with parts of this project and to draft this README.
