import 'package:flutter/material.dart';
import 'package:mouvaps/utils/text_utils.dart';
import 'package:mouvaps/services/exercise.dart';
import 'package:mouvaps/pages/exercise/exercise_widget.dart';

import '../../services/auth.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> with WidgetsBindingObserver {
  late Future<List<Exercise>> _exercisesFuture;

  @override
  void initState() {
    super.initState();
    _exercisesFuture = _getExercises();
  }

    @override
    void dispose() {
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return FutureBuilder(
        future: _exercisesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const H2(content: 'Séances hebdomadaires'),
                if (snapshot.data!.isNotEmpty)
                  ListView.separated(
                    shrinkWrap: true,
                    itemCount: (snapshot.data!.length),
                    itemBuilder: (context, index) {
                      return ExerciseCard(exercise: snapshot.data![index], isEnabled: snapshot.data![index].isUnlocked, onWatchedCallback: _refresh);
                    },
                    separatorBuilder: (context, index) {
                      return const Divider(indent: 15, endIndent: 15,);
                    },
                  )
                else
                  const Center(child: P(content: 'Aucune séance disponible pour le moment.'))
              ],
            );
          }
        },
      );
    }

  Future<List<Exercise>> _getExercises() async {
    return await Auth.instance.hasRole('VERIFIED') ? Exercise.getAll() : Exercise.getDemoExercises();
  }

    void _refresh() async {
      setState(() {
        _exercisesFuture = _getExercises();
      });
    }
  }