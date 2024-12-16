import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color primaryColor;
  final bool isAdmin;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.primaryColor,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    if(isAdmin) {
      int index = currentIndex;
      if(currentIndex > 1) {
        index = 0;
      }
      return BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Utilisateurs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle),
            label: 'Contenus',
          ),
        ],
        currentIndex: index,
        selectedItemColor: primaryColor,
        unselectedItemColor: primaryColor,
        showUnselectedLabels: true,
        onTap: onTap,
      );
    }
    return BottomNavigationBar(
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
      currentIndex: currentIndex,
      selectedItemColor: primaryColor,
      unselectedItemColor: primaryColor,
      showUnselectedLabels: true,
      onTap: onTap,
    );
  }
}