import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:logger/logger.dart';
import 'package:mouvaps/home/recipe/recipe_details_screen.dart';
import 'package:mouvaps/services/recipe.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../constants.dart';

class CustomRecipeWidget extends StatelessWidget {
  final Recipe recipe;
  final bool isLocked;
  const CustomRecipeWidget({
    super.key,
    required this.recipe,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    Logger logger = Logger();
    Widget content = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            recipe.name,
            style: ShadTheme.of(context).textTheme.h3,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  StarRating(
                    rating: recipe.difficulty.toDouble(),
                    color: primaryColor,
                    borderColor: Colors.grey,
                    starCount: 5,
                    size: 20,
                  ),
                  Text(
                    'Difficulté',
                    style: ShadTheme.of(context).textTheme.p,
                  ),
                ],
              ),
              Container(
                margin: const EdgeInsets.only(right: 59.0),
                child: Row(
                  children: [
                    const Icon(Icons.timer, color: primaryColor),
                    Text(
                      '${recipe.timeMins} min',
                      style: ShadTheme.of(context).textTheme.p,
                    ),
                  ],
                ),
              ),
              Material(
                color: primaryColor,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: () => {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          elevation: 5.0,
                          backgroundColor: Colors.white,
                          child: Container(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Ingrédients',
                                  style: ShadTheme.of(context).textTheme.h3,
                                ),
                                const SizedBox(height: 10),
                                Column(
                                  children: recipe.ingredients!
                                      .map(
                                        (ingredient) => Text(
                                          ingredient.name,
                                          style:
                                              ShadTheme.of(context).textTheme.p,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.menu_book,
                      color: lightColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isLocked)
            (Material(
              color: primaryColor,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: () => {logger.i('Débloquer')},
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Débloquer pour ${recipe.pricePoints} points",
                    style: const TextStyle(
                      fontSize: pFontSize,
                      fontWeight: pFontWeight,
                      color: lightColor,
                    ),
                  ),
                ),
              ),
            ))
        ],
      ),
    );

    return Material(
      color: lightColor,
      borderRadius: BorderRadius.circular(20),
      child: isLocked
          ? content
          : InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailsScreen(recipe: recipe),
                  ),
                );
              },
              child: content,
            ),
    );
  }
}
