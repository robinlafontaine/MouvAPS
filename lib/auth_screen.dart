import 'package:flutter/material.dart';
import 'package:mouvaps/home_screen.dart';
import 'package:mouvaps/signin_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  User? _user;
  @override
  void initState() {
    _getAuth();
    super.initState();
  }

  Future<void> _getAuth() async {
    setState(() {
      _user = supabase.auth.currentUser;
    });
    supabase.auth.onAuthStateChange.listen((event) {
      setState(() {
        _user = event.session?.user;
      });
    });
  }

  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getAuth(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          return _user == null ? const SignInScreen() : const HomeScreen();
        }
      },
    );
  }
}