import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:mouvaps/pages/recipe/recipe_details_screen.dart';
import 'package:mouvaps/services/recipe.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:mouvaps/utils/constants.dart';

import '../../services/user.dart';
import '../../notifiers/user_points_notifier.dart';

class CustomRecipeWidget extends StatelessWidget {
  final Recipe recipe;
  final Future<User> user;
  final bool isLocked;
  final VoidCallback onRecipeUnlocked;
  const CustomRecipeWidget({
    super.key,
    required this.recipe,
    required this.isLocked,
    required this.user,
    required this.onRecipeUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    // Define the content of the recipe widget
    Widget content = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Stack(
            children: [
              Center(
                child: Text(
                  recipe.name,
                  style: ShadTheme.of(context).textTheme.h3,
                ),
              ),
              if (isLocked)
                (Positioned(
                  right: 0,
                  child: Text(
                    '${recipe.pricePoints} pts',
                    style: ShadTheme.of(context).textTheme.h4,
                  ),
                ))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(
                  recipe.imageUrl,
                  width: 100,
                ),
              ),
              Column(
                children: [
                  StarRating(
                    rating: recipe.difficulty.toDouble(),
                    color: primaryColor,
                    emptyIcon: CupertinoIcons.circle,
                    filledIcon: CupertinoIcons.circle_fill,
                    halfFilledIcon: CupertinoIcons.circle_lefthalf_fill,
                    borderColor: primaryColor,
                    starCount: 3,
                    size: 20,
                  ),
                  Text(
                    'Difficulté',
                    style: ShadTheme.of(context).textTheme.p,
                  ),
                ],
              ),
              Column(
                children: [
                  const Icon(Icons.timer, color: primaryColor),
                  Text(
                    recipe.timeMins! >= 60
                        ? '${(recipe.timeMins! ~/ 60)}h${(recipe.timeMins! % 60 > 0 ? ' ${(recipe.timeMins! % 60)} min' : '')}'
                        : '${recipe.timeMins} min',
                    style: ShadTheme.of(context).textTheme.p,
                  ),
                ],
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
            FutureBuilder<User>(
              future: user,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  User userData = snapshot.data!;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ShadButton(
                        onPressed: () async {
                          if (userData.points >= (recipe.pricePoints ?? 0)) {
                            bool? result = await showDialog<bool>(
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Déverrouiller ${recipe.name} pour ${recipe.pricePoints} pts ?',
                                          style:
                                              ShadTheme.of(context).textTheme.p,
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            ShadButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(true);
                                              },
                                              child: const Text('Oui'),
                                            ),
                                            ShadButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(false);
                                              },
                                              child: const Text('Annuler'),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );

                            if (result == true) {
                              await recipe.unlockRecipe(userData.userUuid);
                              await userData.updatePoints(
                                  userData.points - (recipe.pricePoints ?? 0));
                              if (!context.mounted) return;
                              Provider.of<UserPointsNotifier>(context,
                                      listen: false)
                                  .addPoints(-(recipe.pricePoints ?? 0));
                              onRecipeUnlocked();
                            }
                          }
                        },
                        enabled: userData.points >= (recipe.pricePoints ?? 0),
                        icon: const Icon(Icons.lock_open, color: lightColor),
                      ),
                    ],
                  );
                } else {
                  return Container();
                }
              },
            )
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
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
      ),
    );
  }
}
