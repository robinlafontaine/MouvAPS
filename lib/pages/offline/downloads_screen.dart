import 'package:flutter/material.dart';
import 'package:mouvaps/pages/recipe/recipe_widget.dart';
import 'package:mouvaps/services/exercise.dart';
import 'package:mouvaps/pages/exercise/exercise_widget.dart';
import 'package:mouvaps/services/recipe.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen>
    with WidgetsBindingObserver {
  late Future<List<Exercise>> _exercisesFuture;
  late Future<List<Recipe>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _exercisesFuture = Exercise.getLocalExercises();
    _recipesFuture = Recipe.getLocalRecipes();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'Téléchargements',
        style: ShadTheme.of(context).textTheme.h1,
      )),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: Future.wait([_exercisesFuture, _recipesFuture]),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final exercises = snapshot.data![0] as List<Exercise>;
              final recipes = snapshot.data![1] as List<Recipe>;

              final details = [
                (
                  title: 'Séances téléchargées',
                  content: exercises.isEmpty
                      ? Column(
                          children: [
                            Center(
                              child: Text(
                                "Aucune séances téléchargées",
                                style: ShadTheme.of(context).textTheme.p,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: exercises.map((exercise) {
                            return ExerciseCard(
                              exercise: exercise,
                              isOffline: true,
                              onWatchedCallback: _refresh,
                            );
                          }).toList(),
                        ),
                ),
                (
                  title: 'Recettes téléchargées',
                  content: recipes.isEmpty
                      ? Column(
                          children: [
                            Center(
                              child: Text(
                                "Aucune recettes téléchargées",
                                style: ShadTheme.of(context).textTheme.p,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: recipes.map((recipe) {
                            return RecipeWidget(
                              recipe: recipe,
                              isLocked: false,
                              isOffline: true,
                              onRecipeStateChanged: _refresh,
                            );
                          }).toList(),
                        ),
                ),
              ];

              return ShadAccordion<({Column content, String title})>.multiple(
                initialValue: [
                  details[0],
                  details[1],
                ],
                children: details.map(
                  (detail) => ShadAccordionItem(
                    value: detail,
                    title: Text(detail.title),
                    titleStyle: ShadTheme.of(context).textTheme.h2,
                    separator: const Divider(indent: 15, endIndent: 15),
                    child: detail.content,
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _refresh() async {
    setState(() {
      _exercisesFuture = Exercise.getLocalExercises();
      _recipesFuture = Recipe.getLocalRecipes();
    });
  }
}
