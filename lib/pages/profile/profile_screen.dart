import 'package:flutter/material.dart';
import 'package:mouvaps/colors.dart';
import 'package:mouvaps/services/auth.dart';
import 'package:mouvaps/pages/profile/profile_switch.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil',
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
          const ProfileSwitch()
        ],
      )
      ),
    );
  }
}
