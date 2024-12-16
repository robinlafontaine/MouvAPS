import 'package:flutter/material.dart';
import 'package:mouvaps/utils/text_utils.dart';

import '../../widgets/carousel_widget.dart';

class SportScreen extends StatelessWidget {
  const SportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          H2(content: 'Précautions'),
          P(
              content:
                  "Avant de faire du sport, il est essentiel de s’échauffer pendant 5 à 10 minutes pour préparer le corps et éviter les blessures. Assure-toi de porter des vêtements et des chaussures adaptés à l’activité, de rester bien hydraté avant, pendant et après l’effort, et de vérifier ton état de santé, surtout si tu as des conditions particulières (consulte un médecin si nécessaire). Choisis un environnement sécurisé, sans obstacles ni dangers, et commence l’exercice progressivement en augmentant l’intensité petit à petit. Enfin, évite de manger un repas copieux juste avant, mais ne fais pas de sport totalement à jeun."),
          H2(content: 'Séances'),
          CustomCarousel(),
          H2(content: 'Étirements'),
          CustomCarousel(),
        ]);
  }
}
