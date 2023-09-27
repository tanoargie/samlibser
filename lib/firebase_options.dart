// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDwur5-Dan5_GI6Pz_eKBle4OyI8V0HAtM',
    appId: '1:782236620420:web:70fe95b9b48ff86c0854d1',
    messagingSenderId: '782236620420',
    projectId: 'samlibser-2bf1e',
    authDomain: 'samlibser-2bf1e.firebaseapp.com',
    storageBucket: 'samlibser-2bf1e.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDAucOl8Txh4x7lYjm7yP9BM9sI8NpVhrQ',
    appId: '1:782236620420:android:21e080e4d8721cc40854d1',
    messagingSenderId: '782236620420',
    projectId: 'samlibser-2bf1e',
    storageBucket: 'samlibser-2bf1e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAkmERvziBN3ik6z6J2BazBwg2NBA5GKlE',
    appId: '1:782236620420:ios:84b2561395d89f200854d1',
    messagingSenderId: '782236620420',
    projectId: 'samlibser-2bf1e',
    storageBucket: 'samlibser-2bf1e.appspot.com',
    androidClientId: '782236620420-0dtsmt0g238jsbqagfqqtimbi78b90m3.apps.googleusercontent.com',
    iosClientId: '782236620420-s9fvvcmtl7kl0sg7b0o0nlao0ps75bc6.apps.googleusercontent.com',
    iosBundleId: 'com.example.samlibser',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAkmERvziBN3ik6z6J2BazBwg2NBA5GKlE',
    appId: '1:782236620420:ios:26ea68922cdad1760854d1',
    messagingSenderId: '782236620420',
    projectId: 'samlibser-2bf1e',
    storageBucket: 'samlibser-2bf1e.appspot.com',
    androidClientId: '782236620420-0dtsmt0g238jsbqagfqqtimbi78b90m3.apps.googleusercontent.com',
    iosClientId: '782236620420-415d1qo80du7s7e2en75ki3fonprn97g.apps.googleusercontent.com',
    iosBundleId: 'com.example.samlibser.RunnerTests',
  );
}