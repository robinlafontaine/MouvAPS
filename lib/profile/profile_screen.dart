import 'package:flutter/material.dart';
import 'package:mouvaps/colors.dart';
import 'package:mouvaps/services/auth.dart';
import 'package:mouvaps/profile/profile_switch.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      body: Center(child:
      Column(
        children: [
          Text(Auth.instance.getUserEmail() ?? ''),
          ProfileSwitch()
        ],
      )
      ),
    );
  }
}
