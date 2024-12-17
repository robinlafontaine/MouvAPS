import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mouvaps/pages/recipe/custom_recipe_widget.dart';
import 'package:mouvaps/services/recipe.dart';
import 'package:mouvaps/services/user.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../services/auth.dart';

class RecipeScreenAccordion extends StatefulWidget {
  const RecipeScreenAccordion({super.key});

  @override
  State<RecipeScreenAccordion> createState() => _RecipeScreenAccordionState();
}

class _RecipeScreenAccordionState extends State<RecipeScreenAccordion> {
  Logger logger = Logger();

  late Future<List<Recipe>> _recipes;
  late Future<List<Recipe>> _unlockedRecipes;
  late Future<User> _user;

  @override
  void initState() {
    super.initState();
    final user = Auth.instance.getUser();
    if (user != null) {
      _recipes = Recipe.getAll();
      _unlockedRecipes = Recipe.getRecipeUnlockedByUserId(user.id);
      _user = User.getByUuid(user.id);
    } else {
      _recipes = Future.value([]);
      _unlockedRecipes = Future.value([]);
      _user = Future.value(User.empty());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
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
            } else if (snapshot.hasData) {
              final recipes = snapshot.data![0] as List<Recipe>;
              final unlockedRecipes = snapshot.data![1] as List<Recipe>;
              final user = snapshot.data![2] as User;

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
                    children: unlockedRecipes.map((recipe) {
                      return CustomRecipeWidget(
                        recipe: recipe,
                        user: _user,
                        isLocked: false,
                      );
                    }).toList(),
                  ),
                ),
                (
                  title: 'Recettes à débloquer (${user.points} points dispo)',
                  content: Column(
                    children: lockedRecipes.map((recipe) {
                      return CustomRecipeWidget(
                        recipe: recipe,
                        user: _user,
                        isLocked: true,
                      );
                    }).toList(),
                  ),
                ),
              ];

              return ShadAccordion<({Column content, String title})>.multiple(
                initialValue: [
                  details[0],
                  details[1]
                ], // CHANGE TO [details[0]] WHEN FINISHED
                children: details.map(
                  (detail) => ShadAccordionItem(
                    value: detail,
                    title: Text(detail.title),
                    child: detail.content,
                  ),
                ),
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
