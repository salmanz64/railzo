# Firebase Setup Guide for Railzo

This guide will help you set up Firebase for your Railway Booking App.

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Enter project name (e.g., `railzo`)
4. Follow the setup wizard and create the project

## Step 2: Add Android App

1. In Firebase Console, click **"Add app"** → **Android**
2. **Android package name**: Enter `com.example.railzo` (or your actual package name)
3. **App nickname**: Enter `Railzo`
4. Download `google-services.json`
5. Copy this file to: `D:\GitHub Desktop\railzo\android\app\`
6. Follow the console instructions for modifying `build.gradle` files (see below)

## Step 3: Modify Android Configuration Files

### File 1: `android/build.gradle` (Project level)

Add the following in the `dependencies` section:
```gradle
buildscript {
    dependencies {
        // ... existing dependencies
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

### File 2: `android/app/build.gradle` (App level)

1. Add this at the TOP of the file:
```gradle
plugins {
    id 'com.android.application'
    id 'kotlin-android'
    // Add this line:
    id 'com.google.gms.google-services'
}
```

2. Add this in the `android` section:
```gradle
android {
    // ... existing config
    defaultConfig {
        // ... existing config
        minSdkVersion 21  // Firebase requires minSdk 21
    }
}
```

## Step 4: Update Firebase Configuration

### File 1: `lib/core/firebase/firebase_config.dart`

Replace the placeholder FirebaseOptions with your actual values from the Firebase Console:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: kIsWeb || const bool.fromEnvironment('dart.vm.product')
            ? null
            : const FirebaseOptions(
                apiKey: 'YOUR_ACTUAL_API_KEY',
                appId: 'YOUR_ACTUAL_APP_ID',
                messagingSenderId: 'YOUR_ACTUAL_MESSAGING_SENDER_ID',
                projectId: 'YOUR_ACTUAL_PROJECT_ID',
              ),
      );
      debugPrint('✅ Firebase initialized successfully');
    } catch (e) {
      debugPrint('❌ Firebase initialization failed: $e');
      rethrow;
    }
  }
}
```

**Where to get these values:**
1. Go to Firebase Console → Project Settings → General
2. Scroll down to "Your apps" section
3. Click on your Android app
4. Copy the values from the configuration snippet

## Step 5: Enable Firestore Database

1. In Firebase Console, go to **Build** → **Firestore Database**
2. Click **"Create database"**
3. Choose location (e.g., `asia-south1` or `us-central1`)
4. Select **Start in Test Mode** (for development)
5. Click **Enable**

## Step 6: Set Firestore Security Rules (Test Mode)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;  // Test mode - CHANGE FOR PRODUCTION
    }
  }
}
```

## Step 7: Initialize Firestore Collections

The app will automatically create these collections when you add data:
- `trains` - Train information
- `routes` - Train routes
- `schedules` - Train schedules
- `bookings` - Booking records
- `passengers` - Passenger data
- `pricing` - Pricing configuration

## Step 8: Final Setup Commands

Run these commands in your project directory:

```bash
# 1. Get dependencies
flutter pub get

# 2. Clean build
flutter clean

# 3. Run the app
flutter run
```

## Optional: Add iOS App (if you want to run on iOS)

1. In Firebase Console, click **"Add app"** → **iOS**
2. **Bundle ID**: Enter your iOS bundle ID
3. Download `GoogleService-Info.plist`
4. Copy to: `D:\GitHub Desktop\railzo\ios\Runner\`

## Troubleshooting

### Issue: "Firebase initialization failed"
- Make sure `google-services.json` is in the correct location
- Verify the package name matches between Firebase and your app

### Issue: "Permission denied in Firestore"
- Check Firestore security rules in Firebase Console
- Make sure database is enabled

### Issue: "No connection to Firestore"
- Check your internet connection
- Verify Firebase project settings allow your app

## Collection Structure Reference

### Trains Collection
```json
{
  "id": "auto-generated",
  "name": "Rajdhani Express",
  "number": "12951",
  "type": "Superfast",
  "availableClasses": ["1st AC", "2nd AC", "3rd AC"],
  "createdAt": "2026-01-15T10:00:00Z"
}
```

### Bookings Collection
```json
{
  "id": "auto-generated",
  "pnr": "PNR1234567890",
  "trainId": "train_id",
  "trainName": "Rajdhani Express",
  "routeId": "route_id",
  "travelClass": "3rd AC",
  "selectedSeats": ["A1-12", "A1-13"],
  "passengers": [
    {"name": "John Doe", "age": 28, "gender": "Male"}
  ],
  "totalAmount": 2400.0,
  "journeyDate": "2026-01-15",
  "status": "Confirmed",
  "bookingDate": "2026-01-15T10:00:00Z",
  "createdAt": "2026-01-15T10:00:00Z"
}
```

## Next Steps

Once setup is complete:
1. Run the app: `flutter run`
2. Test creating a train through Admin Dashboard
3. Verify data appears in Firebase Console → Firestore
4. Test booking functionality
5. Check Firestore to see booking records

## Production Checklist

Before going to production:
- Update Firestore security rules to secure your data
- Enable App Check for additional security
- Set up Firebase Analytics
- Configure Firebase Crashlytics
- Test on real devices (not just emulators)
- Review Firebase quotas and limits

## Firebase Console Links

- [Firestore Database](https://console.firebase.google.com/project/YOUR_PROJECT_ID/firestore)
- [Project Settings](https://console.firebase.google.com/project/YOUR_PROJECT_ID/settings/general)
- [Authentication](https://console.firebase.google.com/project/YOUR_PROJECT_ID/authentication)
