import 'package:firebase_core/firebase_core.dart' as firebase_core;

const firebaseConfig = {
  'apiKey': "AIzaSyDyzLBBbdTZA5pwH1i36iOvm3Rmkc46YWA",
  'authDomain': "oyeshi-70387.firebaseapp.com",
  'projectId': "oyeshi-70387",
  'storageBucket': "oyeshi-70387.firebasestorage.app",
  'messagingSenderId': "586767218576",
  'appId': "1:586767218576:web:7cb6ac721ab16df6072515",
  'measurementId': "G-D61G30HEP7"
};

Future<firebase_core.FirebaseApp> initializeFirebase() async {
  return await firebase_core.Firebase.initializeApp(
    options: firebase_core.FirebaseOptions(
      apiKey: firebaseConfig['apiKey']!,
      authDomain: firebaseConfig['authDomain']!,
      projectId: firebaseConfig['projectId']!,
      storageBucket: firebaseConfig['storageBucket']!,
      messagingSenderId: firebaseConfig['messagingSenderId']!,
      appId: firebaseConfig['appId']!,
      measurementId: firebaseConfig['measurementId'],
    ),
  );
}