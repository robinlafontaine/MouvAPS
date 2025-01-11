import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:mouvaps/utils/constants.dart' as constants;

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isAdmin;


  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    if(isAdmin) {
      int index = currentIndex;
      if(currentIndex > 2) {
        index = 2;
      }
      return BottomNavigationBar(
        items:  <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              index == 0
                  ? PhosphorIcons.users(PhosphorIconsStyle.fill)
                  : PhosphorIcons.users(PhosphorIconsStyle.regular),
            ),
            label: 'Utilisateurs',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              index == 1
                  ? PhosphorIcons.sneakerMove(PhosphorIconsStyle.fill)
                  : PhosphorIcons.sneakerMove(PhosphorIconsStyle.regular),
            ),
            label: 'Séances',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              index == 2
                  ? PhosphorIcons.bowlFood(PhosphorIconsStyle.fill)
                  : PhosphorIcons.bowlFood(PhosphorIconsStyle.regular),
            ),
            label: 'Recettes',
          ),
        ],
          type: BottomNavigationBarType.fixed,
          currentIndex: index,
          selectedItemColor: constants.primaryColor,
          unselectedItemColor: constants.textColor,
          showUnselectedLabels: false,
          showSelectedLabels: true,
        selectedLabelStyle: const TextStyle(
          color: constants.primaryColor,
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          color: constants.primaryColor,
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
          onTap: onTap,
      );
    }
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(
            currentIndex == 0
                ? PhosphorIcons.sneakerMove(PhosphorIconsStyle.fill)
                : PhosphorIcons.sneakerMove(PhosphorIconsStyle.regular),
          ),
          label: 'Séances',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            currentIndex == 1
                ? PhosphorIcons.bowlFood(PhosphorIconsStyle.fill)
                : PhosphorIcons.bowlFood(PhosphorIconsStyle.regular),
          ),
          label: 'Recettes',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            currentIndex == 2
                ? PhosphorIcons.info(PhosphorIconsStyle.fill)
                : PhosphorIcons.info(PhosphorIconsStyle.regular),
          ),
          label: 'Infos',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            currentIndex == 3
                ? PhosphorIcons.chatCircleDots(PhosphorIconsStyle.fill)
                : PhosphorIcons.chatCircleDots(PhosphorIconsStyle.regular),
          ),
          label: 'Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            currentIndex == 4
                ? PhosphorIcons.downloadSimple(PhosphorIconsStyle.fill)
                : PhosphorIcons.downloadSimple(PhosphorIconsStyle.regular),
          ),
          label: 'Téléchargés',
        ),
      ],
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      selectedItemColor: constants.primaryColor,
      unselectedItemColor: constants.textColor,
      showUnselectedLabels: false,
      showSelectedLabels: true,
      selectedLabelStyle: const TextStyle(
        fontFamily: constants.fontFamily,
        color: constants.primaryColor,
        fontSize: 8,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: constants.fontFamily,
        color: constants.primaryColor,
        fontSize: 8,
        fontWeight: FontWeight.w600,
      ),
      onTap: onTap,
    );

  }

  void setState(Null Function() param0) {}
}