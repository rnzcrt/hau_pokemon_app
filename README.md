# HAUPokemon 🎮📍

[![Flutter](https://img.shields.io/badge/Flutter-Framework-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-Language-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)](https://developer.android.com/)
[![AWS EC2](https://img.shields.io/badge/Cloud-AWS%20EC2-FF9900?logo=amazonec2&logoColor=white)](https://aws.amazon.com/ec2/)
[![OpenStreetMap](https://img.shields.io/badge/Maps-OpenStreetMap-7EBC6F?logo=openstreetmap&logoColor=white)](https://www.openstreetmap.org/)
[![REST API](https://img.shields.io/badge/API-HTTP%20%2F%20JSON-4B8BBE)](https://www.json.org/json-en.html)
[![AI Assisted](https://img.shields.io/badge/Development-AI--Assisted-8A2BE2?logo=openai&logoColor=white)](https://openai.com/)
[![Academic Project](https://img.shields.io/badge/Project-Academic-6A737D)](#academic-project)

HAUPokemon is a location-based monster-catching mobile application developed as a **group school project** for a cloud-computing course. Built with Flutter, it combines GPS-based gameplay with a backend API and AWS EC2 status/control features.

> **Project context:** Academic group project. AI tools were used as development assistance where helpful, alongside human implementation, review, debugging, and testing. My contributions focused on Flutter application work, AWS EC2 setup, and bug fixing. The features listed below describe the project as a whole, not necessarily work completed individually by me.

## Features

- **Player accounts:** Register, log in, and log out.
- **Monster collection:** View the monster list and support create, update, and delete operations.
- **Location-based detection:** Use device location to check for nearby monsters.
- **Interactive monster map:** View monster spawn locations and their spawn-radius circles using OpenStreetMap.
- **Catching feedback:** Trigger sound and flashlight feedback when a monster is detected, where supported by the device.
- **Leaderboard:** View top players.
- **Cloud instance status and controls:** Display EC2 instance status and send start/stop control requests through the configured API.

## My Contributions

As a member of the project team, my work included:

- Contributing to the Flutter application.
- Helping set up and configure AWS EC2 for the project.
- Debugging issues and helping fix application problems.
- Using AI-assisted tools as a development aid where appropriate, while reviewing and adapting outputs to the project.

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
| AI-assisted development | AI tools used as assistance for development tasks; outputs should be reviewed and validated |
| Testing and code quality | Flutter Test, Flutter Lints |

## How It Works

1. A player registers or logs in.
2. The app requests location permission when the player uses location-based detection.
3. The app sends authenticated requests to the configured backend to retrieve monsters and check for nearby spawns.
4. The map screen displays monster locations using OpenStreetMap-based map components.
5. The EC2 screen queries the configured cloud API for instance status and sends control requests.

The app depends on reachable backend/API services for several features. Location detection also requires location services and permission on the device.

## Run Locally

### Requirements

- Flutter SDK compatible with the Dart SDK range in `pubspec.yaml`
- Android Studio, VS Code, or another Flutter-supported development environment
- A configured backend/API environment
- A physical device or emulator; a physical device is recommended for GPS and flashlight functionality

### Setup

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd hau_pokemon_app
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Configure the API endpoints in `lib/config/app_config.dart` for an environment you are authorized to use. Do not commit private URLs, access tokens, passwords, or other secrets to a public repository.

4. Check the platform-specific location and other device permissions required by the features you want to test.

5. Run the app:

   ```bash
   flutter run
   ```

> The app will not work fully until its backend/API endpoints are configured and reachable. Some services may require a VPN or a particular network configuration. Do not publish private network addresses or credentials in this README.

## Testing

The repository includes Flutter test dependencies. Before presenting the project, run the checks supported by your environment:

```bash
flutter analyze
flutter test
```

Record the actual results here after running them. Do not describe checks as passing unless you have run them successfully.


## Limitations and Notes

- Location-based features depend on device permissions and location services.
- Backend-dependent features require the configured API to be available.
- Flashlight feedback depends on device hardware and platform permissions.
- AWS instance controls should only be used in the intended project environment and by authorized users.
- AI-assisted development does not replace code review, security review, testing, or verification of generated suggestions.
- Build, test, coverage, release, and license badges are intentionally not included as passing/status badges unless the repository has the corresponding workflow, measured result, release, or license configured.

## Academic Project

Developed collaboratively as a school project at **Holy Angel University**.

This repository demonstrates experience contributing to a Flutter application, working with cloud infrastructure, integrating API-driven functionality, using AI-assisted development tools responsibly, and debugging issues in a team project.
