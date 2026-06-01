# Flutter Setup — Wazni وزني
**بنفس هيكل zyiarah**

---

## المتطلبات
- Flutter SDK 3.x → [flutter.dev](https://flutter.dev/docs/get-started/install)
- Dart SDK 3.x (يأتي مع Flutter)
- Android Studio أو Xcode
- Firebase CLI + FlutterFire CLI

---

## الخطوة 1 — تثبيت التبعيات

```bash
cd C:\Users\denin\erihdev\wazni
flutter pub get
```

---

## الخطوة 2 — ربط Firebase

```bash
# تثبيت FlutterFire CLI
dart pub global activate flutterfire_cli

# ربط المشروع (يستبدل firebase_options.dart تلقائياً)
flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID
```

---

## الخطوة 3 — إضافة Google Services

**Android:** ضعي `google-services.json` في `android/app/`

**iOS:** ضعي `GoogleService-Info.plist` في `ios/Runner/`

(FlutterFire يفعل ذلك تلقائياً عند الخطوة 2)

---

## الخطوة 4 — تشغيل التطبيق

```bash
flutter run                    # على الجهاز المتصل
flutter run -d chrome          # على الويب
flutter run -d emulator-5554   # على محاكي Android
```

---

## الخطوة 5 — البناء للنشر

```bash
# Android
flutter build apk --release    # APK للتجربة
flutter build appbundle --release  # AAB لـ Google Play

# iOS (Mac فقط)
flutter build ipa --release
```

---

## هيكل المشروع

```
lib/
├── main.dart                 ← نقطة البداية + Firebase init
├── router.dart               ← GoRouter (نفس zyiarah)
├── firebase_options.dart     ← يُولَّد بـ flutterfire configure
├── theme/
│   └── app_theme.dart        ← ألوان Wazni + Tajawal font
├── models/
│   ├── user_model.dart
│   └── entry_model.dart
├── providers/
│   └── user_provider.dart    ← ChangeNotifier (نفس ZyiarahUserProvider)
├── services/
│   └── firebase_service.dart ← Singleton (نفس ZyiarahFirebaseService)
├── screens/
│   ├── splash_screen.dart
│   ├── auth_screen.dart
│   ├── home_screen.dart      ← Bottom Nav
│   ├── my_progress_screen.dart
│   ├── challenge_screen.dart
│   └── my_code_screen.dart
└── widgets/
    └── stat_card.dart
```

---

## app identifiers

| Platform | Bundle ID |
|---|---|
| iOS | `com.erihdev.wazni` |
| Android | `com.erihdev.wazni` |

---

## erihdev · [erihdev.com](https://erihdev.com)
