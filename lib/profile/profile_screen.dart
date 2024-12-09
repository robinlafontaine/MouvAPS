import 'package:flutter/material.dart';
import 'package:mouvaps/colors.dart';
import 'package:mouvaps/profile/profile_switch.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  static final supabase = Supabase.instance.client;

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
          Text(supabase.auth.currentUser!.email ?? ''),
          ProfileSwitch()
        ],
      )
      ),
    );
  }
}
