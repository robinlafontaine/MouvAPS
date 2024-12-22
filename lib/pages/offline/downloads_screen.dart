import 'package:flutter/material.dart';
import 'package:mouvaps/utils/text_utils.dart';
import 'package:mouvaps/services/exercise.dart';
import 'package:mouvaps/pages/exercise/exercise_widget.dart';
import 'package:mouvaps/services/recipe.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> with WidgetsBindingObserver {
  late Future<List<Exercise>> _exercisesFuture;
  late Future<List<Recipe>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _exercisesFuture = Exercise.getLocalExercises();
    //_recipesFuture = Recipe.getLocalRecipes();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([_exercisesFuture, _recipesFuture]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final exercises = snapshot.data![0] as List<Exercise>;
          final recipes = snapshot.data![1] as List<Recipe>;

          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const H2(content: 'Séances téléchargées'),
                if (exercises.isNotEmpty)
                  ExpansionTile(
                    title: const Text('Exercises'),
                    children: exercises.map((exercise) {
                      return ExerciseCard(
                        exercise: exercise,
                        isOffline: true,
                        onWatchedCallback: _refresh,
                      );
                    }).toList(),
                  )
                else
                  const Center(child: P(content: 'Aucune séance téléchargée pour le moment.')),

                const H2(content: 'Recettes téléchargées'),
                if (recipes.isNotEmpty)
                  ExpansionTile(
                    title: const Text('Recipes'),
                    children: recipes.map((recipe) {
                      return ListTile(
                        title: Text(recipe.name),
                        subtitle: Text(recipe.description),
                      );
                    }).toList(),
                  )
                else
                  const Center(child: P(content: 'Aucune recette téléchargée pour le moment.')),
              ],
            ),
          );
        }
      },
    );
  }

  void _refresh() async {
    setState(() {
      _exercisesFuture = Exercise.getLocalExercises();
      //_recipesFuture = Recipe.getLocalRecipes();
    });
  }
}