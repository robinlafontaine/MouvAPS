import 'package:flutter/material.dart';
import 'package:mouvaps/auth/home_screen.dart';
import 'package:mouvaps/auth/signin_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthController extends StatefulWidget {
  const AuthController({super.key});

  @override
  State<AuthController> createState() => _AuthControllerState();
}

class _AuthControllerState extends State<AuthController> {
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
    return _user == null ? const SignInScreen() : const HomeScreen();
  }
}