import 'package:firebase_core/firebase_core.dart';
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
    apiKey: 'AIzaSyB36S5xWg2HKfxsds1W3P4BTBL-ibXuJno',
    appId: '1:320574838366:web:47f42bc59d1d5f7efe46cf',
    messagingSenderId: '320574838366',
    projectId: 'mykuliner-a787d',
    authDomain: 'mykuliner-a787d.firebaseapp.com',
    databaseURL: 'https://mykuliner-a787d-default-rtdb.firebaseio.com',
    storageBucket: 'mykuliner-a787d.appspot.com',
    measurementId: 'G-WLZTXV72K7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDJ9_kIHxNpqWS-NyiA0HOrxC-P5i_4BG0',
    appId: '1:320574838366:android:c46d269fa954c863fe46cf',
    messagingSenderId: '320574838366',
    projectId: 'mykuliner-a787d',
    databaseURL: 'https://mykuliner-a787d-default-rtdb.firebaseio.com',
    storageBucket: 'mykuliner-a787d.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB-c1XKGam_QCTxMbFQaWMJ-iRg4o1DfdI',
    appId: '1:320574838366:ios:51be34b71e470e56fe46cf',
    messagingSenderId: '320574838366',
    projectId: 'mykuliner-a787d',
    databaseURL: 'https://mykuliner-a787d-default-rtdb.firebaseio.com',
    storageBucket: 'mykuliner-a787d.appspot.com',
    iosClientId:
        '320574838366-3nl3p5ntpeovh9ed0bq56h8sd1cq6p4c.apps.googleusercontent.com',
    iosBundleId: 'com.example.mykuliner',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB-c1XKGam_QCTxMbFQaWMJ-iRg4o1DfdI',
    appId: '1:320574838366:ios:51be34b71e470e56fe46cf',
    messagingSenderId: '320574838366',
    projectId: 'mykuliner-a787d',
    databaseURL: 'https://mykuliner-a787d-default-rtdb.firebaseio.com',
    storageBucket: 'mykuliner-a787d.appspot.com',
    iosClientId:
        '320574838366-3nl3p5ntpeovh9ed0bq56h8sd1cq6p4c.apps.googleusercontent.com',
    iosBundleId: 'com.example.mykuliner',
  );
}
