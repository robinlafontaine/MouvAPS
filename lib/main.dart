import 'package:flutter/material.dart';
import 'package:mouvaps/auth/auth_controller.dart';
import 'package:mouvaps/home/home_screen.dart';
import 'package:mouvaps/auth/signin_screen.dart';
import 'package:mouvaps/profile/profile_screen.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mouvaps/auth/otp_screen.dart';

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
      debugShowCheckedModeBanner: false,
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
