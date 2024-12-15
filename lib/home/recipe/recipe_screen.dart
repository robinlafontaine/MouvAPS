import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mouvaps/home/recipe/custom_recipe_widget.dart';
import 'package:mouvaps/services/recipe.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class RecetteScreen extends StatefulWidget {
  const RecetteScreen({super.key});

  @override
  State<RecetteScreen> createState() => _RecetteScreenState();
}

class _RecetteScreenState extends State<RecetteScreen> {
  Logger logger = Logger();
  final ExpansionTileController _unlockedController = ExpansionTileController();
  final ExpansionTileController _lockedController = ExpansionTileController();

  final Future<List<Recipe>> _recipes = Recipe.getAll();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder(
                future: _recipes,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    logger.e('Error fetching recipes: ${snapshot.error}');
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    return ExpansionTile(
                      controller: _unlockedController,
                      title: Text('Vos recettes',
                          style: ShadTheme.of(context).textTheme.h2),
                      initiallyExpanded: true,
                      children: snapshot.data!.map((recipe) {
                        return CustomRecipeWidget(
                          title: recipe.name,
                          description: recipe.description,
                          rating: recipe.difficulty.toDouble(),
                          time: recipe.timeMins!,
                          ingredients:
                              recipe.ingredients!.map((e) => e.name).toList(),
                          isLocked: false,
                        );
                      }).toList(),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                }),
            FutureBuilder(
                future: _recipes,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    logger.e('Error fetching recipes: ${snapshot.error}');
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    return ExpansionTile(
                      controller: _lockedController,
                      title: Text('Recettes à débloquer',
                          style: ShadTheme.of(context).textTheme.h2),
                      children: snapshot.data!.map((recipe) {
                        return CustomRecipeWidget(
                          title: recipe.name,
                          description: recipe.description,
                          rating: recipe.difficulty.toDouble(),
                          time: recipe.timeMins!,
                          ingredients:
                              recipe.ingredients!.map((e) => e.name).toList(),
                          isLocked: true,
                          pricePoints: recipe.pricePoints,
                        );
                      }).toList(),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                }),
          ],
        ),
      ),
    );
  }
}
