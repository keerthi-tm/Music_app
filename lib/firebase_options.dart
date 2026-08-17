import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD28nQObApLaFe0zCVTCN6Sw8YwP3-3YIQ',
    appId: '1:759941379163:web:ecd08db24b0e3b26773b7e',
    messagingSenderId: '759941379163',
    projectId: 'landinglogin',
    authDomain: 'landinglogin.firebaseapp.com',
    storageBucket: 'landinglogin.firebasestorage.app',
    measurementId: 'G-L9QBJG53Y6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDS74WrHNJ-IuOMRVI-FKaFwo-JdBnZUJ8',
    appId: '1:759941379163:android:cd2b2350e6e29e7a773b7e',
    messagingSenderId: '759941379163',
    projectId: 'landinglogin',
    storageBucket: 'landinglogin.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD28nQObApLaFe0zCVTCN6Sw8YwP3-3YIQ',
    appId: '1:759941379163:web:aab401c29daefd89773b7e',
    messagingSenderId: '759941379163',
    projectId: 'landinglogin',
    authDomain: 'landinglogin.firebaseapp.com',
    storageBucket: 'landinglogin.firebasestorage.app',
    measurementId: 'G-49K9VP3L5T',
  );
}
