import 'package:flutter/material.dart';
import 'package:mouvaps/pages/admin/widgets/admin_content_list.dart';

import '../../../services/recipe.dart';

class RecipeAdminScreen extends StatefulWidget {
  const RecipeAdminScreen({super.key});

  @override
  State<RecipeAdminScreen> createState() => _RecipeAdminScreenState();
}

class _RecipeAdminScreenState extends State<RecipeAdminScreen> {
  late Future<List<Recipe>> _recipes;

  @override
  void initState() {
    super.initState();
    _recipes = Recipe.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _recipes,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ContentListAdmin(
            recipes: snapshot.data,
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
