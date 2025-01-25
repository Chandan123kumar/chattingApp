// File generated by FlutterFire CLI.
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA5rzvIClgP9SAFQXZjWm-wvgJ9IhxxeqY',
    appId: '1:436573396589:android:f20f696da3bacfc8916964',
    messagingSenderId: '436573396589',
    projectId: 'fir-demo-project-57fd1',
    databaseURL: 'https://fir-demo-project-57fd1-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'fir-demo-project-57fd1.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC92T17MiF_65N6U9wEG_ffmNhIPG98tAE',
    appId: '1:252328139224:ios:bc8dffaa9ce0c92af53aad',
    messagingSenderId: '252328139224',
    projectId: 'storage-application-377b3',
    storageBucket: 'storage-application-377b3.appspot.com',
    iosBundleId: 'com.example.batKaro',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB2YDl_jmAKydtfiAgJ2OnZ75SoF5XOCog',
    appId: '1:252328139224:web:ee7b7213ea1721baf53aad',
    messagingSenderId: '252328139224',
    projectId: 'storage-application-377b3',
    authDomain: 'storage-application-377b3.firebaseapp.com',
    storageBucket: 'storage-application-377b3.appspot.com',
    measurementId: 'G-6XH3Y231ET',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC92T17MiF_65N6U9wEG_ffmNhIPG98tAE',
    appId: '1:252328139224:ios:bc8dffaa9ce0c92af53aad',
    messagingSenderId: '252328139224',
    projectId: 'storage-application-377b3',
    storageBucket: 'storage-application-377b3.appspot.com',
    iosBundleId: 'com.example.batKaro',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB2YDl_jmAKydtfiAgJ2OnZ75SoF5XOCog',
    appId: '1:252328139224:web:9d204f1bb213c49af53aad',
    messagingSenderId: '252328139224',
    projectId: 'storage-application-377b3',
    authDomain: 'storage-application-377b3.firebaseapp.com',
    databaseURL: 'https://storage-application-377b3-default-rtdb.firebaseio.com',
    storageBucket: 'storage-application-377b3.appspot.com',
    measurementId: 'G-JMNG1PRE4Y',
  );

}