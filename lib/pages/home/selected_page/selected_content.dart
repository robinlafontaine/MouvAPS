import 'package:flutter/material.dart';
import 'package:mouvaps/pages/recipe/recipe_screen.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:mouvaps/pages/admin/users/users_page.dart';
import 'package:mouvaps/pages/exercise/exercise_screen.dart';

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
      if (currentIndex > 1) {
        index = 0;
      }
      List<Widget> widgets = <Widget>[
        const UsersPage(),
        Text(
          'Index 1: Contenus',
          style: ShadTheme.of(context).textTheme.h1,
        ),
      ];
      return widgets[index];
    }
    List<Widget> widgets = <Widget>[
      const ExerciseScreen(),
      Text(
        'Index 1: Recettes',
        style: ShadTheme.of(context).textTheme.h1,
      ),
      const RecipeScreen(),
      Text(
        'Index 2: Infos',
        style: ShadTheme.of(context).textTheme.h1,
      ),
      Text(
        'Index 3: Chat',
        style: ShadTheme.of(context).textTheme.h1,
      ),
    ];
    return widgets[currentIndex];
  }
}
