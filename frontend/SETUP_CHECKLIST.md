# ✅ ImplantGuard AI™ — Setup Checklist

Follow these steps in order to get the app running.

---

## 🔥 Firebase Setup (Required First)

- [ ] Create a Firebase project at https://console.firebase.google.com
- [ ] Set project name: `implantguard-ai`
- [ ] **Authentication**: Enable → Email/Password sign-in method
- [ ] **Firestore**: Create database → Start in production mode → Choose region
- [ ] **Storage**: Get started → production mode
- [ ] **Cloud Messaging**: No action needed (auto-enabled)

---

## 📱 Android Setup

- [ ] In Firebase Console → Project Settings → Android app
  - Package name: `com.implantguard.ai`
  - Download `google-services.json`
  - Place in: `android/app/google-services.json`

---

## 🍎 iOS Setup

- [ ] In Firebase Console → Project Settings → iOS app
  - Bundle ID: `com.implantguard.ai`
  - Download `GoogleService-Info.plist`
  - Place in: `ios/Runner/GoogleService-Info.plist`

---

## ⚡ FlutterFire CLI (Auto-generates firebase_options.dart)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Run in project root — this auto-generates lib/firebase_options.dart
flutterfire configure --project=implantguard-ai
```

---

## 🛡️ Deploy Security Rules

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize (select Firestore + Storage)
firebase init

# Deploy rules
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
firebase deploy --only storage
```

---

## 📦 Flutter Setup

```bash
# Get dependencies
flutter pub get

# Check for issues
flutter doctor

# Run on Android
flutter run -d android

# Run on iOS
flutter run -d ios

# Build release APK
flutter build apk --release

# Build release IPA (Mac only)
flutter build ipa
```

---

## 🧪 Test with Firebase Emulator (Optional)

```bash
# Start emulators locally (no real Firebase needed for dev)
firebase emulators:start

# In main.dart, add before Firebase.initializeApp():
# FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
# FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
```

---

## ✔️ Verification Checklist

- [ ] `firebase_options.dart` generated in `lib/`
- [ ] `google-services.json` in `android/app/`
- [ ] `GoogleService-Info.plist` in `ios/Runner/`
- [ ] `flutter pub get` runs without errors
- [ ] App launches on device/emulator
- [ ] Can register a new doctor account
- [ ] Can log in
- [ ] Dashboard loads
- [ ] Can add a patient
- [ ] Can add an implant
- [ ] Can add an assessment
- [ ] AI Prediction screen shows risk analysis

---

## 🔑 Key Configuration Locations

| Item | Location |
|------|---------|
| Firebase config | `lib/firebase_options.dart` |
| Android Firebase | `android/app/google-services.json` |
| iOS Firebase | `ios/Runner/GoogleService-Info.plist` |
| Firestore rules | `firebase/firestore.rules` |
| Storage rules | `firebase/storage.rules` |
| Firestore indexes | `firebase/firestore.indexes.json` |
| App theme | `lib/app.dart` → `_buildTheme()` |
| AI weights | `lib/services/ai_prediction_service.dart` → `_featureWeights` |
| Risk thresholds | `lib/services/ai_prediction_service.dart` → `_classifyRiskLevel()` |

---

## 📞 Common Issues

**`firebase_options.dart not found`**
→ Run `flutterfire configure`

**`google-services.json not found`**
→ Download from Firebase Console and place in `android/app/`

**`Gradle build failed`**
→ Ensure `minSdkVersion 23` in `android/app/build.gradle`

**`Permission denied on Firestore`**
→ Deploy `firebase/firestore.rules` via `firebase deploy --only firestore:rules`

**`CocoaPods issues on iOS`**
→ Run `cd ios && pod install && cd ..`
