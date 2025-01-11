import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mouvaps/utils/constants.dart';

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
      if(currentIndex > 2) {
        index = 0;
      }
      return BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Utilisateurs',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.personRunning),
            label: 'Séances',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.utensils),
            label: 'Recettes',
          ),
        ],
          type: BottomNavigationBarType.fixed,
          currentIndex: index,
          selectedItemColor: primaryColor,
          unselectedItemColor: textColor,
          showUnselectedLabels: false,
          showSelectedLabels: true,
          selectedLabelStyle: TextStyle(
            color: primaryColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          onTap: onTap,
      );
    }
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.personRunning),
          label: 'Séances',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.utensils),
          label: 'Recettes',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.circleInfo),
          label: 'Infos',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.comments),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.download),
          label: 'Local',
        ),
      ],
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: primaryColor,
      unselectedItemColor: textColor,
      showUnselectedLabels: false,
      showSelectedLabels: true,
      selectedLabelStyle: TextStyle(
        color: primaryColor,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      onTap: onTap,
    );
  }

  void setState(Null Function() param0) {}
}