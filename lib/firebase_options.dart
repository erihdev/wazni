// ════════════════════════════════════════════════════════
//  ⚠️  هذا الملف يُولَّد تلقائياً بواسطة FlutterFire CLI
//  اتبعي خطوات FIREBASE_SETUP.md لتوليده
// ════════════════════════════════════════════════════════
//
//  الأمر:
//    dart pub global activate flutterfire_cli
//    flutterfire configure --project=YOUR_PROJECT_ID
//
//  بعد التشغيل سيُستبدل هذا الملف بالإعدادات الحقيقية.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return android;
      case TargetPlatform.iOS:     return ios;
      default: throw UnsupportedError('Platform not supported');
    }
  }

  // ← استبدلي القيم بعد تشغيل: flutterfire configure
  static const FirebaseOptions web = FirebaseOptions(
    apiKey:            'AIzaSyBcYp-WzM3lLpRLweAI7k-lObAsaFhrguA',
    appId:             '1:293723234164:web:bb7cdb09f96702945b9621',
    messagingSenderId: '293723234164',
    projectId:         'wazni-902b8',
    authDomain:        'wazni-902b8.firebaseapp.com',
    storageBucket:     'wazni-902b8.firebasestorage.app',
    measurementId:     'G-Q5RJKGQF3L',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD9PIzXTHk4ukO1alUpWt-w32951IxMaes',
    appId: '1:293723234164:android:481b5bb5701ff7995b9621',
    messagingSenderId: '293723234164',
    projectId: 'wazni-902b8',
    storageBucket: 'wazni-902b8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBWITcCygYQJJri2lL-f3zGVU1LnzAdUm0',
    appId: '1:293723234164:ios:fc88cc94908a20a05b9621',
    messagingSenderId: '293723234164',
    projectId: 'wazni-902b8',
    storageBucket: 'wazni-902b8.firebasestorage.app',
    iosBundleId: 'com.erihdev.wazni',
  );

}