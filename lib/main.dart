import 'package:flutter/material.dart';
import 'package:mouvaps/auth/auth_router.dart';
import 'package:mouvaps/pages/form/name_form_screen.dart';
import 'package:mouvaps/pages/home/home_screen.dart';
import 'package:mouvaps/auth/signin_screen.dart';
import 'package:mouvaps/pages/offline/downloads_screen.dart';
import 'package:mouvaps/pages/profile/profile_screen.dart';
import 'package:mouvaps/services/db.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mouvaps/auth/otp_screen.dart';
import 'package:mouvaps/utils/constants.dart' as constants;
import 'package:provider/provider.dart';
import 'package:mouvaps/notifiers/user_points_notifier.dart';

Future main() async {
  await dotenv.load(fileName: ".env");

  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );
  await ContentDatabase.instance.database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserPointsNotifier(),
      child: ShadApp.material(
        debugShowCheckedModeBanner: false,
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
                fontFamily: constants.fontFamily,
                fontSize: constants.h1FontSize,
                fontWeight: FontWeight.w400,
                fontVariations:[
                  FontVariation(
                      'wght', constants.h1FontWeight
                  )
                ],
                color: constants.primaryColor,
              ),
              h2: const TextStyle(
                fontFamily: constants.fontFamily,
                fontSize: constants.h2FontSize,
                fontWeight: FontWeight.w400,
                fontVariations:[
                  FontVariation(
                      'wght', constants.h2FontWeight
                  )
                ],
                color: constants.secondaryColor,
              ),
              h3: const TextStyle(
                fontFamily: constants.fontFamily,
                fontSize: constants.h3FontSize,
                fontWeight: FontWeight.w400,
                fontVariations:[
                  FontVariation(
                      'wght', constants.h3FontWeight
                  )
                ],
                color: constants.textColor,
              ),
              h4: const TextStyle(
                fontFamily: constants.fontFamily,
                fontSize: constants.h4FontSize,
                fontWeight: FontWeight.w400,
                fontVariations:[
                  FontVariation(
                    'wght', constants.h4FontWeight
                  )
                ],
                color: constants.textColor,
              ),
              p: const TextStyle(
                fontFamily: constants.fontFamily,
                fontSize: constants.pFontSize,
                fontWeight: FontWeight.w400,
                fontVariations:[
                  FontVariation(
                      'wght', constants.pFontWeight
                  )
                ],
                color: constants.textColor,
              ),
              small: const TextStyle(
                fontFamily: constants.fontFamily,
                fontSize: constants.smallFontSize,
                fontWeight: FontWeight.w400,
                fontVariations:[
                  FontVariation(
                      'wght', constants.smallFontWeight
                  )
                ],
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
            switchTheme: const ShadSwitchTheme(
              checkedTrackColor: constants.primaryColor,
            )),
        title: "Mouv'APS",
        initialRoute: '/',
        routes: {
          '/': (context) => const AuthRouter(),
          '/home': (context) => const HomeScreen(),
          '/signin': (context) => const SignInScreen(),
          '/otp': (context) => OTPScreen(
              email: ModalRoute.of(context)!.settings.arguments as String),
          '/profile': (context) => ProfileScreen(),
          '/offline': (context) => const DownloadsScreen(),
          '/form': (context) => const NameFormScreen(),
        },
      ),
    );
  }
}
