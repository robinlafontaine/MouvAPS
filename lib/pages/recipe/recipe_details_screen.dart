import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../services/recipe.dart';

class RecipeDetailsScreen extends StatelessWidget {
  final Recipe recipe;

  const RecipeDetailsScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name, style: ShadTheme.of(context).textTheme.h1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: MarkdownBody(data: recipe.description)),
      ),
    );
  }
}
