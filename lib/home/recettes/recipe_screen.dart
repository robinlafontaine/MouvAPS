import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mouvaps/home/recettes/custom_recipe_widget.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class RecetteScreen extends StatefulWidget {
  const RecetteScreen({super.key});

  @override
  State<RecetteScreen> createState() => _RecetteScreenState();
}

class _RecetteScreenState extends State<RecetteScreen> {
  Logger logger = Logger();
  final ExpansionTileController _unlockedController = ExpansionTileController();
  final ExpansionTileController _lockedController = ExpansionTileController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpansionTile(
              controller: _unlockedController,
              title: Text('Vos recettes',
                  style: ShadTheme.of(context).textTheme.h2),
              children: const [
                CustomRecipeWidget(
                    title: "Poulet rôti",
                    rating: 3,
                    time: 30,
                    ingredients: ["Poulet", "Huile"],
                    isLocked: false),
              ],
            ),
            ExpansionTile(
              controller: _lockedController,
              title: Text('Recettes à débloquer',
                  style: ShadTheme.of(context).textTheme.h2),
              children: const [
                CustomRecipeWidget(
                  title: "Poulet rôti",
                  rating: 3,
                  time: 30,
                  ingredients: ["Poulet", "Huile"],
                  isLocked: true,
                  pricePoints: 10,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
