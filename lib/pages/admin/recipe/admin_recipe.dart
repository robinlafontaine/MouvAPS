import 'package:flutter/material.dart';
import 'package:mouvaps/services/recipe.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AdminRecipe extends StatefulWidget {
  final Recipe? recipe;
  final bool? newRecipe;

  const AdminRecipe({super.key, this.recipe, this.newRecipe})
      : assert(recipe != null || newRecipe != null,
            'recipe or newRecipe must be provided');

  @override
  State<StatefulWidget> createState() {
    return _AdminRecipeState();
  }
}

class _AdminRecipeState extends State<AdminRecipe> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.recipe != null ? widget.recipe!.name : 'New Recipe',
          style: ShadTheme.of(context).textTheme.h1,
        ),
      ),
      body: _buildRecipeContent(),
    );
  }

  Widget _buildRecipeContent() {
    // Implement the exercise content UI here
    return const Center(child: Text('Exercise Content'));
  }
}
