import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oyeshi_des/bloc/theme/theme_bloc.dart';
import 'package:oyeshi_des/themes/app_theme.dart';
import 'bloc/theme/theme_state.dart';
import 'pages/FirstPage.dart';
import 'pages/IngredientInputScreen.dart';
import 'widgets/no_glow_scroll_behaviour.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

  runApp(const MyApp());
}

class OyeshiApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(
          create: (_) => ThemeBloc(),
        )
      ],
      child: MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(builder: (context, themeState) {
      return MaterialApp(
        title: "Oyeshi Des App",
        debugShowCheckedModeBanner: false,
        theme: themeState.isDarkMode ? AppTheme.dark : AppTheme.light,
        home: const IngredientInputScreen(),
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
