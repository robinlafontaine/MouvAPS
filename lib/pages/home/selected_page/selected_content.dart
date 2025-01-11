import 'package:flutter/material.dart';
import 'package:mouvaps/pages/offline/downloads_screen.dart';
import 'package:mouvaps/pages/recipe/recipe_screen.dart';
import 'package:mouvaps/utils/text_utils.dart';
import 'package:mouvaps/pages/exercise/exercise_screen.dart';
import 'package:mouvaps/pages/admin/users/users_screen.dart';

class SelectedPage extends StatelessWidget {
  final int currentIndex;
  final bool isAdmin;

  const SelectedPage({
    super.key,
    required this.currentIndex,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    if (isAdmin) {
      int index = currentIndex;
      if (currentIndex > 2) {
        index = 2;
      }
      List<Widget> widgets = const <Widget>[
        UsersPage(),
        H2(content: 'En construction...'),
        H2(content: 'En construction...'),
      ];
      return widgets[index];
    }
    List<Widget> widgets = const <Widget>[
      ExerciseScreen(),
      RecipeScreen(),
      H2(content: 'En construction...'),
      H2(content: 'En construction...'),
      DownloadsScreen(),
    ];
    return widgets[currentIndex];
  }
}
