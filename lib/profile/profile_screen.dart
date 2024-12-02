import 'package:flutter/material.dart';

import '../colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Screen'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.account_circle,
              color: primaryColor,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: const Center(child: Text('Profile Screen')),
    );
  }
}
