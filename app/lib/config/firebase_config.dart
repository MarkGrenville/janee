import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static const String projectId = 'janee-dev';

  static const int authEmulatorPort = 6411;
  static const int firestoreEmulatorPort = 6412;
  static const int storageEmulatorPort = 6415;
  static const int functionsEmulatorPort = 6413;

  static const FirebaseOptions webOptions = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:000000000000:web:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: projectId,
    authDomain: 'localhost',
    storageBucket: '$projectId.appspot.com',
  );

  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: kIsWeb ? webOptions : null,
    );

    if (_shouldUseEmulators()) {
      await _connectToEmulators();
    }
  }

  static bool _shouldUseEmulators() {
    // Always use emulators in debug mode
    return kDebugMode;
  }

  static Future<void> _connectToEmulators() async {
    final host = kIsWeb ? 'localhost' : '10.0.2.2';
    print('[FirebaseConfig] Connecting to emulators at $host');

    try {
      await FirebaseAuth.instance.useAuthEmulator(host, authEmulatorPort);
      print('[FirebaseConfig] Auth emulator connected on port $authEmulatorPort');
    } catch (e) {
      print('[FirebaseConfig] Auth emulator already configured: $e');
    }

    try {
      FirebaseFirestore.instance.useFirestoreEmulator(host, firestoreEmulatorPort);
      print('[FirebaseConfig] Firestore emulator connected on port $firestoreEmulatorPort');
    } catch (e) {
      print('[FirebaseConfig] Firestore emulator already configured: $e');
    }

    try {
      await FirebaseStorage.instance.useStorageEmulator(host, storageEmulatorPort);
      print('[FirebaseConfig] Storage emulator connected on port $storageEmulatorPort');
    } catch (e) {
      print('[FirebaseConfig] Storage emulator already configured: $e');
    }

    print('[FirebaseConfig] All emulators connected');
  }
}
