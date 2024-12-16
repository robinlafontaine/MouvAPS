import 'package:flutter/material.dart';
import 'package:mouvaps/utils/text_utils.dart';
import 'package:mouvaps/services/exercise.dart';
import 'package:mouvaps/pages/home/exercise_widget.dart';

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  @override
Widget build(BuildContext context) {
  return FutureBuilder(
    future: Exercise.getAll(),
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
            const H2(content: 'Précautions'),
            const P(
                content: "Avant de faire du sport, il est essentiel de s’échauffer pendant 5 à 10 minutes pour préparer le corps et éviter les blessures. Assure-toi de porter des vêtements et des chaussures adaptés à l’activité, de rester bien hydraté avant, pendant et après l’effort, et de vérifier ton état de santé, surtout si tu as des conditions particulières (consulte un médecin si nécessaire). Choisis un environnement sécurisé, sans obstacles ni dangers, et commence l’exercice progressivement en augmentant l’intensité petit à petit. Enfin, évite de manger un repas copieux juste avant, mais ne fais pas de sport totalement à jeun."
            ),
            const H2(content: 'Séances'),
            if (snapshot.data!.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data?.length,
                itemBuilder: (context, index) {
                  return ExerciseCard(exercise: snapshot.data![index]);
                },
              ),
        ]);
      }
    },
  );
}
}
