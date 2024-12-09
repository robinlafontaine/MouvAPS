import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'caroussel_widget.dart';

class SportScreen extends StatelessWidget {
  const SportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('Précautions',
                  style: ShadTheme.of(context).textTheme.h2),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 8.0),
              child: Text(
                  "Avant de faire du sport, il est essentiel de s’échauffer pendant 5 à 10 minutes pour préparer le corps et éviter les blessures. Assure-toi de porter des vêtements et des chaussures adaptés à l’activité, de rester bien hydraté avant, pendant et après l’effort, et de vérifier ton état de santé, surtout si tu as des conditions particulières (consulte un médecin si nécessaire). Choisis un environnement sécurisé, sans obstacles ni dangers, et commence l’exercice progressivement en augmentant l’intensité petit à petit. Enfin, évite de manger un repas copieux juste avant, mais ne fais pas de sport totalement à jeun."),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Séances',
                style: ShadTheme.of(context).textTheme.h2,
              ),
            ),
            const CustomCarousel(),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child:
                  Text('Étirements', style: ShadTheme.of(context).textTheme.h2),
            ),
            const CustomCarousel(),
          ],
        ),
      ),
    );
  }
}
