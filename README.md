# Hipster Video (Flutter)

Modern Flutter video calling app with authentication, user list (REST + offline cache), and ZegoCloud video SDK integration. Ready for day‑1 testing and CI builds.

Note: We are sharing an Android APK for easy install. This app is also fully compatible with iOS; build and run on iOS requires a Mac with Xcode and appropriate signing/profiles.

## Quick Start

### Demo Login (for reviewers)
- Any email is accepted if the password is exactly `123456`.
- You can also use any email shown in the in-app User List (tap Team tab) to log in; the same password rule applies (`123456`).
- Suggested demo emails (auto-avatar + name mapping):
  - `john.doe@test.com`  (John Doe)
  - `jane.smith@test.com` (Jane Smith)

If you use another email, the name will be derived from the local part (e.g., `alice.wong@x.com` → Alice Wong).

### ZegoCloud SDK Configuration
The app is pre-wired with demo credentials (for development/testing). Update with your own before publishing:

File: `lib/config/zego_config.dart`
```dart
class ZegoConfig {
  // Replace with your own for production
  static const int appId = 1900407899; 
  static const String appSign = '1079a4b819eba711a99a5763891145d4ad9321980d54b26b28cbbb5ea0d3d051';
}
```

Alternatively use compile‑time environment values for security (see comments in the file).

### Build & Run
```bash
flutter pub get
flutter run
```

Build APK:
```bash
flutter build apk --release
```

Android App Bundle:
```bash
flutter build appbundle --release
```

iOS (requires macOS/Xcode):
```bash
flutter build ios --release
```

## Features
- Authentication via mock + ReqRes fallback
- User list from REST API with SQLite offline cache
- One‑to‑one video calls (ZegoUIKitPrebuiltCall)
- Screen sharing button in call UI
- Professional error toasts for call invitations
- Clean UI with Material 3
- Prefilled attendee name on Dashboard from logged‑in user

### Chat (App Messaging)
- A simple chat screen is included for navigation and UI demonstration.
- How to open: from the Team (User List) screen, tap the message icon beside a user.
- Current behavior: local dummy chat UI (header, message list, input field) without a backend.
- Limitations: no real-time messaging, no persistence; intended as a scaffold for future integration.

## Tech Stack
- Flutter (stable)
- BLoC + Equatable
- HTTP (reqres.in) + SharedPreferences + Sqflite
- ZegoUIKit Prebuilt Call (video)

## App Configuration

### Permissions
Android: `android/app/src/main/AndroidManifest.xml`
- INTERNET, ACCESS_NETWORK_STATE, ACCESS_WIFI_STATE
- CAMERA, RECORD_AUDIO, MODIFY_AUDIO_SETTINGS
- WAKE_LOCK, VIBRATE, SYSTEM_ALERT_WINDOW
- FOREGROUND_SERVICE, FOREGROUND_SERVICE_MEDIA_PROJECTION (screen sharing)

iOS: `ios/Runner/Info.plist`
- NSCameraUsageDescription
- NSMicrophoneUsageDescription

### Versioning & Signing
`pubspec.yaml`: `version: 1.0.0+1`

Android signing (release):
1. Create a keystore (one‑time):
   ```bash
   keytool -genkey -v -keystore my-release-key.keystore -alias upload -keyalg RSA -keysize 2048 -validity 10000
   ```
2. Create `keystore.properties` at project root (do not commit):
   ```
   storeFile=/absolute/path/to/my-release-key.keystore
   storePassword=your-store-password
   keyAlias=upload
   keyPassword=your-key-password
   ```
3. Build signed artifacts:
   ```bash
   flutter build apk --release
   flutter build appbundle --release
   ```

iOS signing (release):
1. Open `ios/Runner.xcworkspace` in Xcode.
2. Set your Team, Bundle Identifier, and Provisioning Profile.
3. Ensure iOS Deployment Target is 13.0+ (Podfile configured).
4. Build/Archive from Xcode or:
   ```bash
   flutter build ios --release
   ```

## CI/CD
GitHub Actions workflow builds a debug APK on every push/PR to main/master.

File: `.github/workflows/flutter-ci.yml`
- Analyze, test, build debug APK
- Uploads artifact `app-debug-apk`

Accessing artifact: In the PR or workflow run page → Artifacts → download APK.

## Push Notifications (Zego)
- Zego signaling integration handles incoming call notifications while the app is in the foreground.
- Background push notifications are not enabled in this project.

### How to test notifications/incoming calls
1. Log in on two different devices/emulators (use any emails; password `123456`).
2. On Device A, open the Team (User List) tab.
3. Tap the video icon next to the user who is logged in on Device B.
4. Device B will show the incoming call UI/foreground notification.
   - Note: Background push is not enabled; bring the app to foreground to see it.

## How Auth Works
`lib/services/auth_service.dart`
- If password == `123456`: creates a local user profile and logs in.
- Otherwise, attempts ReqRes `POST /login`; on success, fetches a sample user profile.
- Session is stored in SharedPreferences and restored on app launch.

## Chat Details
- Entry point: `lib/screens/chat_screen.dart`
- Reached via the message icon on `lib/screens/user_list_screen.dart` list items.
- Replace with your messaging backend (e.g., Firebase/Socket.IO) as needed.

## Notes on Stability
- Orientation: default Flutter behavior; call UI is handled by Zego prebuilt UI.
- Lifecycle: SDK initializes on login and cleans up on logout.
- Tested on physical Android device; recommended to grant camera/mic.

## Troubleshooting
- Video/camera not working: ensure camera/mic permissions, real device recommended.
- Build failures: `flutter clean && flutter pub get`.
- Zego errors: verify `appId`/`appSign` in `ZegoConfig`.

## Roadmap / Nice‑to‑Have
- External camera support (if SDK exposes it)
- Push notifications for incoming calls (mocked/FCM)
- iOS/macOS CI job with code signing
- Release signing templates and secure secrets

## License
For demo/educational use. Ensure proper licenses for any third‑party SDKs for production.