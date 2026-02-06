import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:oyeshi_des/bloc/text_scan/text_scan_bloc.dart';
import 'package:oyeshi_des/bloc/theme/theme_bloc.dart';
import 'package:oyeshi_des/bloc/theme/theme_state.dart';
import 'package:oyeshi_des/bloc/ingredient_input/ingredient_input_bloc.dart';
import 'package:oyeshi_des/themes/app_theme.dart';
import 'package:oyeshi_des/pages/input_method_selection_screen.dart';
import 'package:oyeshi_des/widgets/no_glow_scroll_behaviour.dart';
import 'package:oyeshi_des/config/dependency_injection.dart';
import 'package:oyeshi_des/repositories/ingredient_repository.dart';
import 'package:oyeshi_des/services/ai_service.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  await setupApp();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

  // await initializeApp(
  //   name:"oyeshi-70387",
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  //   name: "oyeshi-70387",
  // );

  runApp(const OyeshiApp());
}

class OyeshiApp extends StatelessWidget {
  const OyeshiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(
          create: (_) => ThemeBloc(),
        ),
        RepositoryProvider<AIService>(create: (_)=>getIt<AIService>(),),
        BlocProvider<TextScanBloc>(
          create: (_) => TextScanBloc(
            aiService: getIt<AIService>(),
          ),
        ),
        BlocProvider<IngredientInputBloc>(
          create: (_) => IngredientInputBloc(
            ingredientRepository: getIt<IngredientRepository>(),
            aiService: getIt<AIService>(),
            userId: 'demo_user', // Replace with actual user ID after auth
          ),
        ),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(builder: (context, themeState) {
      return MaterialApp(
        title: "Oyeshi Des App",
        debugShowCheckedModeBanner: false,
        theme: themeState.isDarkMode ? AppTheme.dark : AppTheme.light,
        home: const InputMethodSelectionScreen(),
        builder: (context, child) {
          return ScrollConfiguration(
            behavior: const NoGlowScrollBehaviour(),
            child: child!,
          );
        },
      );
    });
  }
}
