---
description: How to build and install the Flutter app on mobile devices
---

# Deploying Your App to Mobile Devices

To use your application on a real mobile phone, you need to "build" it into an installable format (**APK** for Android or **IPA** for iOS).

## 1. Android Installation (Easiest)

### Step 1: Build the APK
Run the following command in your terminal (`school_app` directory):
```powershell
flutter build apk --release
```
This generates a file at: `build/app/outputs/flutter-apk/app-release.apk`

### Step 2: Transfer to Phone
- Copy the `app-release.apk` file to your mobile phone via USB, Google Drive, or WhatsApp.
- On your phone, open the file to install it. 
- *Note: You may need to enable "Install from Unknown Sources" in your phone's settings.*

### Step 3: Multiple Phones
You can share this same `.apk` file with as many Android phones as you want. Each person can install it and use the app.

---

## 2. iOS Installation (Requires Mac)

### Step 1: Build for iOS
Run the following command:
```powershell
flutter build ios --release
```

### Step 2: Distribute
iOS is more restricted. To install on multiple phones without the App Store, you can use:
- **TestFlight** (Official Apple testing tool)
- **Firebase App Distribution**

---

## 3. Production (Play Store & App Store)
When you are ready for the world to see your app:
1. **Android**: Upload the `.aab` (Android App Bundle) to [Google Play Console](https://play.google.com/console).
2. **iOS**: Upload the build via Xcode to [App Store Connect](https://appstoreconnect.apple.com).
