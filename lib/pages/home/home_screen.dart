import 'package:flutter/material.dart';
import 'package:mouvaps/pages/home/custom_bottom_navigation.dart';
import 'package:mouvaps/pages/home/selected_page/selected_title.dart';
import 'package:mouvaps/constants.dart';
import 'package:mouvaps/globals/globals.dart' as globals;
import 'package:mouvaps/pages/home/selected_page/selected_content.dart';
import 'package:mouvaps/pages/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SelectedTitle(currentIndex: _selectedIndex, isAdmin: globals.isAdmin),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.account_circle,
              color: primaryColor,
              size: 36,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const ProfileScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      var begin = const Offset(1.0, 0.0);
                      var end = Offset.zero;
                      var curve = Curves.ease;

                      var tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  ),
                 ).then((_) {
                setState(() {});
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
            child: SelectedPage(currentIndex: _selectedIndex, isAdmin: globals.isAdmin),
          ),
        ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: _selectedIndex, onTap: _onItemTapped, primaryColor: primaryColor, isAdmin: globals.isAdmin),
    );
  }
}
