import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:oyeshi_des/firebase_options.dart';
import 'package:oyeshi_des/repositories/ingredient_repository.dart';
import 'package:oyeshi_des/services/ai_service.dart';
import 'package:oyeshi_des/services/audio_input_service.dart';
import 'package:oyeshi_des/config/firebase_config.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // register firebase firestore.
  getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);

  getIt.registerSingleton<IngredientRepository>(
    FirebaseIngredientRepository(getIt<FirebaseFirestore>()),
  );

  getIt.registerLazySingleton<AIService>(
    () => GeminiAIService('AIzaSyAkv-YXTCLyL8N1d1fqlTor1o4vhgHeG4Q'),
  );

  getIt.registerLazySingleton<AudioInputService>(
    () => SpeechToTextService(),
  );
}

Future<void> setupApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
    name: "oyeshi-70387",
  );

  await configureDependencies();
}

Future<void> initializeApp({required FirebaseOptions options}) async {
  await initializeFirebase();
  await configureDependencies();
}
