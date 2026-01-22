# Firebase Implementation Summary

## ✅ What Has Been Implemented

### 1. Firebase Dependencies Added (`pubspec.yaml`)
- `firebase_core: ^3.6.0` - Firebase core functionality
- `cloud_firestore: ^5.4.4` - Firestore database
- `firebase_analytics: ^11.3.3` - Analytics (optional)

### 2. Firebase Configuration (`lib/core/firebase/`)
- **`firebase_config.dart`** - Firebase initialization with `FirebaseOptions`
- **`firestore_service.dart`** - Generic Firestore service layer with CRUD operations

### 3. Models Updated with Firebase Support
All models now have proper `toJson()` and `fromJson()` methods:
- `lib/data/models/booking.dart` - Booking model
- `lib/data/models/passenger.dart` - Passenger model
- `lib/data/models/train.dart` - Train model (already had methods)
- `lib/data/models/route.dart` - Route model (already had methods)
- `lib/data/models/schedule.dart` - New Schedule model created
- `lib/data/models/pricing.dart` - New Pricing model created

### 4. Repositories Migrated to Firebase
All repositories now use Firestore instead of mock data:
- **`lib/data/repositories/admin_train_repository.dart`** - Trains CRUD
- **`lib/data/repositories/booking_repository.dart`** - Bookings CRUD
- **`lib/data/repositories/passenger_repository.dart`** - Passengers CRUD
- **`lib/data/repositories/admin_route_repository.dart`** - Routes CRUD
- **`lib/data/repositories/admin_schedule_repository.dart`** - Schedules CRUD
- **`lib/data/repositories/admin_pricing_repository.dart`** - Pricing CRUD

### 5. View Models Updated
All view models now use typed models instead of `Map<String, dynamic>`:
- `lib/presentation/admin/viewmodels/train_view_model.dart`
- `lib/presentation/admin/viewmodels/route_view_model.dart`
- `lib/presentation/admin/viewmodels/schedule_view_model.dart`
- `lib/presentation/admin/viewmodels/pricing_view_model.dart`
- `lib/presentation/passenger/viewmodels/booking_view_model.dart`
- `lib/presentation/passenger/viewmodels/passenger_view_model.dart`
- `lib/presentation/user/booking_view_model.dart`

### 6. App Initialization Updated (`lib/main.dart`)
- Firebase initialization added to `main()` function
- `WidgetsFlutterBinding.ensureInitialized()` called before Firebase init

## 📋 What YOU Need To Do

### Step 1: Create Firebase Project (5 minutes)
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"**
3. Enter project name (e.g., `railzo`)
4. Create the project

### Step 2: Add Android App to Firebase (5 minutes)
1. In Firebase Console → **Build** → click **"Add app"** → **Android**
2. **Android package name**: Enter `com.example.railzo`
   - Find this in: `android/app/build.gradle` → `applicationId`
3. **App nickname**: Enter `Railzo`
4. Click **Register app**
5. Download `google-services.json`
6. Copy to: `D:\GitHub Desktop\railzo\android\app\google-services.json`

### Step 3: Modify Android Gradle Files (5 minutes)

#### File 1: `android/build.gradle` (Project level)
Add to `dependencies` section:
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

#### File 2: `android/app/build.gradle` (App level)
1. Add at the TOP of the file:
```gradle
plugins {
    id 'com.android.application'
    id 'kotlin-android'
    id 'com.google.gms.google-services'
}
```

2. In `android` section, ensure:
```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Firebase requires minSdk 21
    }
}
```

### Step 4: Update FirebaseConfig with Your Credentials (2 minutes)

Open `lib/core/firebase/firebase_config.dart` and replace the placeholders:

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
                apiKey: 'YOUR_ACTUAL_API_KEY',           // REPLACE THIS
                appId: 'YOUR_ACTUAL_APP_ID',            // REPLACE THIS
                messagingSenderId: 'YOUR_ACTUAL_MESSAGING_SENDER_ID',  // REPLACE THIS
                projectId: 'YOUR_ACTUAL_PROJECT_ID',      // REPLACE THIS
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

**How to get these values:**
1. Go to Firebase Console → Project Settings → General
2. Scroll down to "Your apps"
3. Click on your Android app
4. You'll see a configuration snippet with these values
5. Copy them into the code above

### Step 5: Enable Firestore Database (3 minutes)
1. In Firebase Console → **Build** → **Firestore Database**
2. Click **"Create database"**
3. Choose a location (recommended: `asia-south1`)
4. Select **Start in Test Mode** (for development)
5. Click **Enable**

### Step 6: Set Firestore Security Rules (2 minutes)

In Firebase Console → Firestore → **Rules** tab, set:
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

### Step 7: Install Dependencies (1 minute)
```bash
cd "D:\GitHub Desktop\railzo"
flutter pub get
```

### Step 8: Run the App (1 minute)
```bash
flutter clean
flutter run
```

## 🗂️ Firestore Collections

The app will automatically create these collections when data is added:

| Collection | Purpose |
|-----------|---------|
| `trains` | Train information (name, number, type, classes) |
| `routes` | Train routes (source, destination, stops, distance) |
| `schedules` | Train schedules (departure times, days) |
| `bookings` | Booking records (PNR, passengers, seats, amount) |
| `passengers` | Passenger details |
| `pricing` | Pricing configuration (per class, GST, charges) |

## 🧪 Testing Your Setup

1. **Run the app**: `flutter run`
2. Go to Admin Dashboard → Manage Trains
3. Create a test train
4. Go to Firebase Console → Firestore
5. You should see the train in the `trains` collection
6. Test booking functionality
7. Check Firestore for booking records

## 🔐 Production Security Rules (DO NOT USE IN PRODUCTION)

Before launching to production, update Firestore rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Only authenticated users can read/write
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## 📚 Additional Resources

- **Setup Guide**: See `FIREBASE_SETUP.md` for detailed instructions
- **Firebase Console**: https://console.firebase.google.com/
- **Firestore Documentation**: https://firebase.google.com/docs/firestore
- **FlutterFire Docs**: https://firebase.flutter.dev/

## ❓ Troubleshooting

### "Firebase initialization failed"
- Check that `google-services.json` is in `android/app/` folder
- Verify package name matches between Firebase and `build.gradle`
- Ensure Firebase project is created and app is registered

### "Permission denied in Firestore"
- Check Firestore security rules in Firebase Console
- Make sure database is enabled (not locked)
- Test mode should allow all reads/writes

### "No data showing in app"
- Check Firebase Console → Firestore to verify data exists
- Check app logs for errors (use `flutter run` and look at console)
- Verify network connection

### Build errors
- Run: `flutter clean`
- Run: `flutter pub get`
- Delete `.dart_tool` folder and run build_runner again

## ✨ Next Steps After Setup

1. **Test all CRUD operations** in admin panel
2. **Test user booking flow** end-to-end
3. **Verify data in Firebase Console**
4. **Test on real Android device** (not just emulator)
5. **Update security rules** for production
6. **Enable Firebase Analytics** (optional but recommended)
7. **Set up Firebase Crashlytics** (optional but recommended)

## 📱 Android Package Name

Your app's package name is typically found in:
`android/app/build.gradle` → `applicationId`

If you want to change it:
1. Update `android/app/build.gradle`
2. Re-add app to Firebase Console with new package name
3. Download new `google-services.json`

## 🎯 Success Criteria

You'll know Firebase is working when:
- ✅ App starts without Firebase initialization errors
- ✅ You can create a train in Admin panel
- ✅ Data appears in Firebase Console → Firestore
- ✅ You can book tickets
- ✅ Booking data saves to Firestore
- ✅ You can fetch and display data from Firestore

## 🆘 Support

If you encounter issues:
1. Check `FIREBASE_SETUP.md` for detailed instructions
2. Review Firebase Console for any error messages
3. Check app logs: `flutter run` (shows console output)
4. Verify all files are in correct locations
5. Ensure internet connection is active

---

**Estimated Total Setup Time**: ~25 minutes

**Good luck with your Firebase setup! 🚀**
