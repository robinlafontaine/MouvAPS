import 'package:flutter/material.dart';
import 'package:mouvaps/admin/home_screen.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
          appBarTheme: const AppBarTheme(toolbarHeight: 52),
        );
      },
      theme: ShadThemeData(
        colorScheme: const ShadBlueColorScheme.light(),
        brightness: Brightness.light,
    ),
      title: "Mouv'APS",
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen()
      },
    );
  }
}


