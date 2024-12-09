import 'package:flutter/material.dart';
import 'package:mouvaps/colors.dart';
import 'package:mouvaps/home/custom_bottom_navigation.dart';
import 'package:mouvaps/home/selected_page/selected_title.dart';
import 'package:mouvaps/home/sport_screen.dart';
import 'package:mouvaps/globals/globals.dart' as globals;
import 'package:mouvaps/home/selected_page/selected_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const TextStyle optionStyle = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );

  late List<Widget> _widgetOptions;
  late List<String> _appBarTitles;

  @override
  void initState() {
    super.initState();

    if (globals.isAdmin) {
      _widgetOptions = <Widget>[
        Text(
          'Index 0: Users',
          style: optionStyle,
        ),
        Text(
          'Index 1: Content',
          style: optionStyle,
        ),
      ];

      _appBarTitles = <String>[
        'Users',
        'Content',
      ];
    } else {
      _widgetOptions = <Widget>[
        SportScreen(),
        Text(
          'Index 1: Recettes',
          style: optionStyle,
        ),
        Text(
          'Index 2: Infos',
          style: optionStyle,
        ),
        Text(
          'Index 3: Chat',
          style: optionStyle,
        ),
      ];

      _appBarTitles = <String>[
        'Programme',
        'Recettes',
        'Informations',
        'Discussions',
      ];
    }
  }

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
              Navigator.pushNamed(context, '/profile').then((_) {
                setState(() {});
              });
            },
          ),
        ],
      ),
      body: Center(
        child: SelectedPage(currentIndex: _selectedIndex, isAdmin: globals.isAdmin),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: _selectedIndex, onTap: _onItemTapped, primaryColor: primaryColor, isAdmin: globals.isAdmin),
    );
  }
}
