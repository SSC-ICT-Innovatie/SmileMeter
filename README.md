# 🙂 😐 😕 SmileMeter
An interactive feedback kiosk, developed using Flutter and a Raspberry Pi.


## Installation
```
  sudo pip install evdev matplotlib

```

## Start the kiosk

```
  python3 smilemeter_kiosk.py

```

# Flutter

```
flutter pub get

```

🔥 3. Configure Firebase
Go to Firebase Console

Create a project → Add an Android or Web app.

Download the google-services.json (Android) or run flutterfire configure for Web.

Place google-services.json in android/app/.

Android only: Edit android/build.gradle and android/app/build.gradle as per Firebase setup.


```
 flutter run
```

Deploy on PI with https://github.com/ardera/flutter-pi