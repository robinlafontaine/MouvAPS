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

  late Future<List<Recipe>> _recipes;
  late Future<List<Recipe>> _unlockedRecipes;
  late Future<User> _user;

  void _refreshRecipes() {
    setState(() {
      final user = Auth.instance.getUser();
      if (user != null) {
        _recipes = Recipe.getAll();
        _unlockedRecipes = Recipe.getRecipeUnlockedByUserId(user.id);
        _user = User.getUserByUuid(user.id);
      } else {
        _recipes = Future.value([]);
        _unlockedRecipes = Future.value([]);
        _user = Future.value(User.empty());
      }
    });
  }

  @override
  void initState() {
    super.initState();
    final user = Auth.instance.getUser();
    if (user != null) {
      _recipes = Recipe.getAll();
      _unlockedRecipes = Recipe.getRecipeUnlockedByUserId(user.id);
      _user = User.getUserByUuid(user.id);
    } else {
      _recipes = Future.value([]);
      _unlockedRecipes = Future.value([]);
      _user = Future.value(User.empty());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FutureBuilder(
        future: Future.wait([
          _recipes.catchError((error) {
            logger.e('Error fetching recipes: $error');
            return <Recipe>[];
          }),
          _unlockedRecipes.catchError((error) {
            logger.e('Error fetching unlocked recipes: $error');
            return <Recipe>[];
          })
        ]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            logger.e('Error fetching recipes: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final recipes = snapshot.data![0] as List<Recipe>;
            final unlockedRecipes = snapshot.data![1] as List<Recipe>;

            // Filter out the recipes that are already unlocked
            final lockedRecipes = recipes
                .where((recipe) =>
                    !unlockedRecipes.map((e) => e.id).contains(recipe.id))
                .toList();

            // Create the accordion details
            final details = [
              (
                title: 'Vos recettes',
                content: Column(
                  children: [
                    for (var recipe in unlockedRecipes) ...[
                      CustomRecipeWidget(
                        recipe: recipe,
                        user: _user,
                        isLocked: false,
                        onRecipeUnlocked: _refreshRecipes,
                      ),
                      const SizedBox(height: 8.0), // Add space between tiles
                    ],
                  ],
                ),
              ),
              (
                title: 'Recettes à débloquer',
                content: Column(
                  children: [
                    for (var recipe in lockedRecipes) ...[
                      CustomRecipeWidget(
                        recipe: recipe,
                        user: _user,
                        isLocked: true,
                        onRecipeUnlocked: _refreshRecipes,
                      ),
                      const SizedBox(height: 8.0), // Add space between tiles
                    ],
                  ],
                ),
              ),
            ];

            return ShadAccordion<({Column content, String title})>.multiple(
              initialValue: [
                details[0],
              ],
              children: details.map(
                (detail) => ShadAccordionItem(
                  value: detail,
                  title: Text(detail.title),
                  titleStyle: ShadTheme.of(context).textTheme.h2,
                  child: detail.content,
                ),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
