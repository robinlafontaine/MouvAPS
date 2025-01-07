import 'package:flutter/material.dart';
import 'package:mouvaps/auth/signin_screen.dart';
import 'package:mouvaps/pages/home/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mouvaps/pages/form/name_form_screen.dart';
import 'package:mouvaps/services/user.dart' as user_data;

class AuthRouter extends StatelessWidget {
  const AuthRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final isLoggedIn = snapshot.data?.session != null;

        if (isLoggedIn) {
          return FutureBuilder<bool>(
            future: user_data.User.exists(Supabase.instance.client.auth.currentUser!.id),
            builder: (context, formSnapshot) {
              if (!formSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final isFormCompleted = formSnapshot.data ?? false;

              return isFormCompleted
                  ? const HomeScreen()
                  : const NameFormScreen();
            },
          );
        } else {
          return const SignInScreen();
        }
      },
    );
  }
}