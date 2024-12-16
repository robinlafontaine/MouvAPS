import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mouvaps/pages/recipe/custom_recipe_widget.dart';
import 'package:mouvaps/services/recipe.dart';
import 'package:mouvaps/services/user.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../services/auth.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  Logger logger = Logger();
  final ExpansionTileController _unlockedController = ExpansionTileController();
  final ExpansionTileController _lockedController = ExpansionTileController();

  final Future<List<Recipe>> _recipes = Recipe.getAll();
  final Future<List<Recipe>> _unlockedRecipes =
      Recipe.getRecipeUnlockedByUserId(Auth.instance.getUser()!.id);
  final Future<User> _user = User.getByUuid(Auth.instance.getUser()!.id);

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
              future: _unlockedRecipes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  logger.e('Error fetching data: ${snapshot.error}');
                  return const Center(
                      child: Icon(
                    Icons.warning,
                    color: Colors.red,
                  ));
                } else if (snapshot.hasData && snapshot.data != null) {
                  return ExpansionTile(
                    controller: _unlockedController,
                    title: Text(
                      'Vos recettes',
                      style: ShadTheme.of(context).textTheme.h2,
                    ),
                    initiallyExpanded: true,
                    children: snapshot.data!.map((recipe) {
                      return CustomRecipeWidget(
                        isLocked: false,
                        recipe: recipe,
                      );
                    }).toList(),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            FutureBuilder(
              future: Future.wait([
                _recipes.catchError((error) {
                  logger.e('Error fetching recipes: $error');
                  return <Recipe>[];
                }),
                _unlockedRecipes.catchError((error) {
                  logger.e('Error fetching unlocked recipes: $error');
                  return <Recipe>[];
                }),
                _user.catchError((error) {
                  logger.e('Error fetching user: $error');
                  return User.empty();
                })
              ]),
              builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  logger.e('Error fetching recipes: ${snapshot.error}');
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data != null) {
                  final recipes = snapshot.data![0] as List<Recipe>;
                  final unlockedRecipes = snapshot.data![1] as List<Recipe>;
                  final user = snapshot.data![2] as User;

                  // Filter out the recipes that are already unlocked
                  final lockedRecipes = recipes
                      .where((recipe) =>
                          !unlockedRecipes.map((e) => e.id).contains(recipe.id))
                      .toList();
                  logger.i('Locked recipes: $lockedRecipes');
                  return ExpansionTile(
                    controller: _lockedController,
                    title: Text(
                      'Recettes à débloquer (${user.points} points)',
                      style: ShadTheme.of(context).textTheme.h2,
                    ),
                    children: lockedRecipes.map((recipe) {
                      return CustomRecipeWidget(
                        recipe: recipe,
                        isLocked: true,
                      );
                    }).toList(),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
