import 'package:flutter/material.dart';
import 'package:mouvaps/colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: primaryColor,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(child: Text(Auth.instance.getUserEmail() ?? '')),
    );
  }
}
