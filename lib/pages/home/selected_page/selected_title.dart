import 'package:flutter/material.dart';
import 'package:mouvaps/utils/text_utils.dart';

class SelectedTitle extends StatelessWidget {
  final int currentIndex;
  final bool isAdmin;

  const SelectedTitle({
    super.key,
    required this.currentIndex,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    if (isAdmin) {
      int index = currentIndex;
      if(currentIndex > 2) {
        index = 0;
      }
      List<Widget> widgets = const <Widget>[
        H1(content: 'Utilisateurs'),
        H1(content: 'Séances'),
        H1(content: 'Recettes'),
      ];
      return widgets[index];
    }
    List<Widget> widgets = const <Widget>[
      H1(content: 'Séances'),
      H1(content: 'Recettes'),
      H1(content: 'Infos'),
      H1(content: 'Chat'),
      H1(content: 'Téléchargements'),
    ];
    return widgets[currentIndex];
  }
}