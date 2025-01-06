import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:mouvaps/utils/text_utils.dart';

Future<bool> showPrecautionDialog(BuildContext context) async {
  final bool? result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        child: ShadDialog.alert(
          title: const Text('Précautions'),
          description: const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: P(content:
              "Avant de faire du sport, il est essentiel de s'échauffer pendant 5 à 10 minutes pour préparer le corps et éviter les blessures. Assure-toi de porter des vêtements et des chaussures adaptés à l'activité, de rester bien hydraté avant, pendant et après l'effort, et de vérifier ton état de santé, surtout si tu as des conditions particulières (consulte un médecin si nécessaire). Choisis un environnement sécurisé, sans obstacles ni dangers, et commence l'exercice progressivement en augmentant l'intensité petit à petit. Enfin, évite de manger un repas copieux juste avant, mais ne fais pas de sport totalement à jeun.",
            ),
          ),
          actions: [
            ShadButton(
              child: const Text('J\'ai compris'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );
    },
  );

  return result ?? false;
}