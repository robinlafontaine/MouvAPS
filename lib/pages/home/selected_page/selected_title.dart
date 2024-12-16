import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
    if(isAdmin) {
      int index = currentIndex;
      if(currentIndex > 1) {
        index = 0;
      }
      List<Widget> widgets = <Widget>[
        Text(
          'Utilisateurs',
          style: ShadTheme.of(context).textTheme.h1,
        ),
        Text(
          'Contenus',
          style: ShadTheme.of(context).textTheme.h1,
        ),
      ];
      return widgets[index];
    }
    List<Widget> widgets = <Widget>[
      Text(
        'Séances',
        style: ShadTheme.of(context).textTheme.h1,
      ),
      Text(
        'Recettes',
        style: ShadTheme.of(context).textTheme.h1,
      ),
      Text(
        'Infos',
        style: ShadTheme.of(context).textTheme.h1,
      ),
      Text(
        'Chat',
        style: ShadTheme.of(context).textTheme.h1,
      ),
    ];
    return widgets[currentIndex];
  }
}