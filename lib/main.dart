import 'package:flutter/material.dart';
import 'package:mouvaps/auth/auth_controller.dart';
import 'package:mouvaps/home/home_screen.dart';
import 'package:mouvaps/auth/signin_screen.dart';
import 'package:mouvaps/profile/profile_screen.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mouvaps/auth/otp_screen.dart';

import 'constants.dart' as Constants;

Future main() async {
  await dotenv.load(fileName: ".env");

  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp.material(
      materialThemeBuilder: (context, theme) {
        return theme.copyWith(
          appBarTheme: const AppBarTheme(
            toolbarHeight: 52,
          ),
        );
      },
      themeMode: ThemeMode.light,
      theme: ShadThemeData(
        colorScheme: const ShadSlateColorScheme.light(),
        brightness: Brightness.light,

        // TYPOGRAPHY
        textTheme: ShadTextTheme(
          h1: const TextStyle(
            fontSize: Constants.h1_font_size,
              fontWeight: Constants.h1_font_weight,
              color: Constants.primary_color,),

          h2: const TextStyle(
            fontSize: Constants.h2_font_size,
              fontWeight: Constants.h2_font_weight,
              decoration: TextDecoration.underline,
              color: Constants.secondary_color,
          ),

          h3: const TextStyle(
            fontSize: Constants.h3_font_size,
              fontWeight: Constants.h3_font_weight,
              color: Constants.text_color,),

          p: const TextStyle(
            fontSize: Constants.p_font_size,
              fontWeight: Constants.p_font_weight,
              color: Constants.text_color,),

          small: const TextStyle(
            fontSize: Constants.small_font_size,
              fontWeight: Constants.small_font_weight,
              color: Constants.text_color,),


        ),

        // BUTTONS
        primaryButtonTheme: const ShadButtonTheme(
          backgroundColor: Constants.primary_color,
        ),
        destructiveButtonTheme: const ShadButtonTheme(
          backgroundColor: Constants.destructive_button_color,
          hoverBackgroundColor: Constants.destructive_button_hover_color,
        ),


    ),
      title: "Mouv'APS",
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthController(),
        '/home': (context) => const HomeScreen(),
        '/signin': (context) => const SignInScreen(),
        '/otp': (context) => OTPScreen(email: ModalRoute.of(context)!.settings.arguments as String),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}


