import 'package:flutter/material.dart';
import 'package:mouvaps/home/home_screen.dart';
import 'package:mouvaps/auth/signin_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth.dart';

class AuthController extends StatefulWidget {
  const AuthController({super.key});

  @override
  State<AuthController> createState() => _AuthControllerState();
}

class _AuthControllerState extends State<AuthController> {
  User? get _user => Auth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    Auth.instance.initialize().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return _user == null ? const SignInScreen() : const HomeScreen();
  }
}
