import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../services/exercise.dart';
import '../../../services/recipe.dart';

class AdminNewContent extends StatelessWidget {
  final Recipe? recipe;
  final Exercise? exercise;

  const AdminNewContent({super.key, this.recipe, this.exercise});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          recipe != null
              ? recipe!.name
              : exercise != null
                  ? exercise!.name
                  : 'New Content',
          style: ShadTheme.of(context).textTheme.h1,
        ),
      ),
      body: const Center(
        child: Text('New Content'),
      ),
    );
  }
}
