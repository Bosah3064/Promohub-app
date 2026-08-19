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

  // TODO: Replace these with your actual Firebase configuration via FlutterFire CLI

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC7DGibP5G0c3-kQvLW9J0eUNFxWHzgVCU',
    appId: '1:148879298385:web:444465eaba75edb3ba0d70',
    messagingSenderId: '148879298385',
    projectId: 'promohub-ce87d',
    authDomain: 'promohub-ce87d.firebaseapp.com',
    databaseURL: 'https://promohub-ce87d-default-rtdb.firebaseio.com',
    storageBucket: 'promohub-ce87d.firebasestorage.app',
    measurementId: 'G-R42X5WTEWY',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBy_vqkJD5930qHDsuizAsfeaOHRzA5SJM',
    appId: '1:148879298385:android:ecb0d617a504b5a6ba0d70',
    messagingSenderId: '148879298385',
    projectId: 'promohub-ce87d',
    databaseURL: 'https://promohub-ce87d-default-rtdb.firebaseio.com',
    storageBucket: 'promohub-ce87d.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDoUtpfw2L-0zQgQmFZywi0vyzkZrwm_QE',
    appId: '1:148879298385:ios:79f3766d713edec6ba0d70',
    messagingSenderId: '148879298385',
    projectId: 'promohub-ce87d',
    databaseURL: 'https://promohub-ce87d-default-rtdb.firebaseio.com',
    storageBucket: 'promohub-ce87d.firebasestorage.app',
    iosClientId: '148879298385-ep5cdvr7tkkpos34qquml6sdbvecgf5d.apps.googleusercontent.com',
    iosBundleId: 'com.promohub.app.testProject',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'REPLACE_ME_MACOS_API_KEY',
    appId: 'REPLACE_ME_MACOS_APP_ID',
    messagingSenderId: 'REPLACE_ME_SENDER_ID',
    projectId: 'promohub-app',
    storageBucket: 'promohub-app.appspot.com',
    iosBundleId: 'com.example.promohub.RunnerTests',
  );
}
