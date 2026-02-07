# hello-world - Instagram Clone (Flutter)
 
Welcome to my first GitHub repository!
 
## About Me
- 🎯 Learning Flutter Development  
- 🌱 Currently studying in a year-long Flutter program
- 💡 Passionate about creating amazing mobile apps
 
## My Goals
- [ ] Master Flutter and Dart
- [ ] Learn State management (BLoC/Riverpod)
- [ ] Build and publish my first app
- [ ] Contribute to open source
 
## Skills I'm Developing
- Flutter & Dart
- Git & GitHub
- Figma for UI/UX design
- Mobile development best practices
 
## Today's Achievement
- [x] Learned Git basics
- [x] Cloned my first repository
- [x] Learn to commit from terminal
 
---
 
# Instagram Clone Project
 
## Project Description
Full-featured Instagram clone built with Flutter and Firebase. Created as part of a year-long Flutter development program with additional self-implemented features like geolocation.
 
## 🚀 Key Features
- **User Authentication** (Firebase Auth)
- **Post Feed** with photos and videos
- **Create Posts** with media content
- **📍 Geolocation** - added independently (determines location, converts to address, saves to Firestore, displays in feed)
- **User Profiles** with follow system
- **Likes, Comments, Shares**
- **Firebase Firestore & Storage** for data and media
 
## 🛠️ Tech Stack
- **Flutter 3.0+**, **Dart 3.0+**
- **Firebase** (Authentication, Firestore, Storage)
- **Geolocation API** (geolocator + geocoding packages)
- **Cloudinary** for media optimization
- **Additional Packages**: video_player, image_picker, carousel_slider, provider
 
## 📱 Getting Started
 
### Prerequisites
- Flutter SDK 3.0+
- Android Studio / VS Code
- Firebase account
 
### Installation
```bash
git clone https://github.com/maria-popova-dev/hello-world.git
cd hello-world
flutter pub get
```
 
Firebase Setup
 
1. Create project in Firebase Console
2. Add iOS and Android apps
3. Download configuration files:
   · google-services.json → android/app/
   · GoogleService-Info.plist → ios/Runner/
4. Enable Authentication, Firestore, Storage
 
Run the App
 
```bash
flutter run
```
 
📁 Project Structure
 
```
lib/
├── main.dart
├── screens/           # App screens
├── posts/             # Post logic (models, services)
├── user-profile/      # User profiles
├── home/              # Feed and media
├── services/          # Business logic
│   └── location_service.dart  # Geolocation service
├── app.components/    # Reusable UI components
└── util/              # Helper utilities
```
 
🎯 What I Learned
 
· Full mobile app development cycle
· Firebase integration (Auth, Firestore, Storage)
· State management with Provider
· Working with native APIs (geolocation)
· Platform-specific configuration (iOS/Android)
· Git version control and collaboration
 
👩‍💻 Developer
 
Maria Popova
Flutter Developer | Year-Long Program Graduate
 
· Email: maria.popova.dev@outlook.com
· GitHub: maria-popova-dev
 
---
 
'The journey of a thousand miles begins with a single step.'
This repository documents my journey from Git beginner to Flutter developer.
