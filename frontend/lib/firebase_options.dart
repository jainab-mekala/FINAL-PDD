// File generated for ImplantGuard AI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyCffX_jBfCmsAWGeuEXJDFbKL_shEg3hLo',
    appId: '1:706848168654:web:6a2625dc811989dedf8e9f',
    messagingSenderId: '706848168654',
    projectId: 'implant-42f2c',
    authDomain: 'implant-42f2c.firebaseapp.com',
    databaseURL: 'https://implant-42f2c-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'implant-42f2c.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDR9bq3OqyDGyDf2nEaWK2PXYpcCGwM718',
    appId: '1:706848168654:android:efb3a12103f80161df8e9f',
    messagingSenderId: '706848168654',
    projectId: 'implant-42f2c',
    databaseURL: 'https://implant-42f2c-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'implant-42f2c.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBRVyUe3uVgluXRMKYpYN-yS_VpsoIlqlw',
    appId: '1:706848168654:ios:d09eeeb016facf57df8e9f',
    messagingSenderId: '706848168654',
    projectId: 'implant-42f2c',
    databaseURL: 'https://implant-42f2c-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'implant-42f2c.firebasestorage.app',
    iosClientId: '706848168654-k2us33rnmahioql27s47au8d1ba2it36.apps.googleusercontent.com',
    iosBundleId: 'com.example.medical',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBRVyUe3uVgluXRMKYpYN-yS_VpsoIlqlw',
    appId: '1:706848168654:ios:d09eeeb016facf57df8e9f',
    messagingSenderId: '706848168654',
    projectId: 'implant-42f2c',
    databaseURL: 'https://implant-42f2c-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'implant-42f2c.firebasestorage.app',
    iosClientId: '706848168654-k2us33rnmahioql27s47au8d1ba2it36.apps.googleusercontent.com',
    iosBundleId: 'com.example.medical',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCffX_jBfCmsAWGeuEXJDFbKL_shEg3hLo',
    appId: '1:706848168654:web:1681a30a23765f46df8e9f',
    messagingSenderId: '706848168654',
    projectId: 'implant-42f2c',
    authDomain: 'implant-42f2c.firebaseapp.com',
    databaseURL: 'https://implant-42f2c-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'implant-42f2c.firebasestorage.app',
  );
}
