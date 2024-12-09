import 'package:flutter/material.dart';
import 'package:mouvaps/colors.dart';
import 'package:mouvaps/home/sport_screen.dart';

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
  static const List<Widget> _widgetOptions = <Widget>[
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

  static const List<String> _appBarTitles = <String>[
    'Programme',
    'Recettes',
    'Informations',
    'Discussions',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _appBarTitles.elementAt(_selectedIndex),
          style: const TextStyle(
            color: primaryColor,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.account_circle,
              color: primaryColor,
              size: 36,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Sport',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Recettes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Infos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.live_help),
            label: 'Chat',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: primaryColor,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
