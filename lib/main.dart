import 'package:flutter/material.dart';

import 'package:mouvaps/auth/auth_router.dart';
import 'package:mouvaps/home/home_screen.dart';
import 'package:mouvaps/auth/signin_screen.dart';
import 'package:mouvaps/profile/profile_screen.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth/otp_screen.dart';

import 'constants.dart' as constants;

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
          family: 'Poppins',

          h1: const TextStyle(
            fontSize: constants.h1FontSize,
            fontWeight: constants.h1FontWeight,
            color: constants.primaryColor,
          ),
          h2: const TextStyle(
            fontSize: constants.h2FontSize,
            fontWeight: constants.h2FontWeight,
            decoration: TextDecoration.underline,
            color: constants.secondaryColor,
          ),
          h3: const TextStyle(
            fontSize: constants.h3FontSize,
            fontWeight: constants.h3FontWeight,
            color: constants.textColor,
          ),
          p: const TextStyle(
            fontSize: constants.pFontSize,
            fontWeight: constants.pFontWeight,
            color: constants.textColor,
          ),
          small: const TextStyle(
            fontSize: constants.smallFontSize,
            fontWeight: constants.smallFontWeight,
            color: constants.textColor,
          ),
        ),

        // BUTTONS
        primaryButtonTheme: const ShadButtonTheme(
          backgroundColor: constants.primaryColor,
        ),
        destructiveButtonTheme: const ShadButtonTheme(
          backgroundColor: constants.destructiveButtonColor,
          hoverBackgroundColor: constants.destructiveButtonHoverColor,
        ),
      ),
      title: "Mouv'APS",
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthRouter(),
        '/home': (context) => const HomeScreen(),
        '/signin': (context) => const SignInScreen(),
        '/otp': (context) => OTPScreen(
            email: ModalRoute.of(context)!.settings.arguments as String),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
