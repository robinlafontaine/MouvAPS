import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Action for settings
              print("Settings clicked");
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to the Home Screen!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Action for button 1
                print('Button 1 clicked');
              },
              child: const Text('Button 1'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Action for button 2
                print('Button 2 clicked');
              },
              child: const Text('Button 2'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                // Action for button 3
                print('Button 3 clicked');
              },
              child: const Text('Button 3'),
            ),
          ],
        ),
      ),
    );
  }
}
