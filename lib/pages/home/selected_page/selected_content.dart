import 'package:flutter/material.dart';
import 'package:mouvaps/pages/admin/recipe/recipe_admin_screen.dart';
import 'package:mouvaps/pages/recipe/recipe_screen.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:mouvaps/pages/exercise/exercise_screen.dart';
import 'package:mouvaps/pages/admin/users/users_screen.dart';

import '../../admin/exercise/exercise_admin_screen.dart';

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
        index = 0;
      }
      List<Widget> widgets = <Widget>[
        const UsersPage(),
        const ExerciseAdminScreen(),
        const RecipeAdminScreen(),
      ];
      return widgets[index];
    }
    List<Widget> widgets = <Widget>[
      const ExerciseScreen(),
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
