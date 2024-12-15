import 'package:flutter/material.dart';
import 'package:mouvaps/auth/signin_screen.dart';
import 'package:mouvaps/home/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

        return isLoggedIn
            ? const HomeScreen()
            : const SignInScreen();
      },
    );
  }
}