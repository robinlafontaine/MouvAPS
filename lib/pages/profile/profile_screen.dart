import 'package:flutter/material.dart';
import 'package:mouvaps/services/auth.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:mouvaps/pages/profile/profile_switch.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: ShadTheme.of(context).textTheme.h1),
      ),
      body: Center(
          child: Column(
        children: [
          Text(Auth.instance.getUserEmail() ?? ''),
          const ProfileSwitch()
        ],
      )),
    );
  }
}
