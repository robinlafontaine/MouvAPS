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

class RecipeWidget extends StatefulWidget {
  final Recipe recipe;
  final Future<User> user;
  final bool isLocked;
  final VoidCallback onRecipeUnlocked;

  const RecipeWidget({
    super.key,
    required this.recipe,
    required this.isLocked,
    required this.user,
    required this.onRecipeUnlocked,
  });

  @override
  State<StatefulWidget> createState() => _RecipeWidgetState();
}

class _RecipeWidgetState extends State<RecipeWidget> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(8),
      enabled: !widget.isLocked,
      tileColor: lightColor,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image(
            image: NetworkImage(widget.recipe.imageUrl),
            fit: BoxFit.cover,
            errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
              return Image.asset(
                'assets/images/default_exercise_image.jpg',
                fit: BoxFit.cover,
              );
            },
          ),
        ),
      ),
      title: Text(
        widget.recipe.name,
        style: ShadTheme.of(context).textTheme.h3,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
              widget: StarRating(
                rating: widget.recipe.difficulty.toDouble(),
                color: primaryColor,
                emptyIcon: CupertinoIcons.circle,
                filledIcon: CupertinoIcons.circle_fill,
                halfFilledIcon: CupertinoIcons.circle_lefthalf_fill,
                borderColor: primaryColor,
                starCount: 3,
                size: 20,
              ),
              text: "Difficulté"),
          _buildInfoRow(
            icon: Icons.timer,
            text: widget.recipe.timeMins! >= 60
                ? '${(widget.recipe.timeMins! ~/ 60)}h${(widget.recipe.timeMins! % 60 > 0 ? ' ${(widget.recipe.timeMins! % 60)} min' : '')}'
                : '${widget.recipe.timeMins} min',
          ),
          _buildInfoRow(
            icon: Icons.payments,
            text: '${widget.recipe.pricePoints} points',
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isLocked)
            FutureBuilder<User>(
              future: widget.user,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  User userData = snapshot.data!;
                  bool canUnlock =
                      userData.points >= (widget.recipe.pricePoints ?? 0);
                  return IconButton(
                    onPressed: canUnlock
                        ? () async {
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
                                          'Déverrouiller ${widget.recipe.name} pour ${widget.recipe.pricePoints} pts ?',
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
                              await widget.recipe
                                  .unlockRecipe(userData.userUuid);
                              await userData.updatePoints(userData.points -
                                  (widget.recipe.pricePoints ?? 0));
                              if (!context.mounted) return;
                              Provider.of<UserPointsNotifier>(context,
                                      listen: false)
                                  .addPoints(-(widget.recipe.pricePoints ?? 0));
                              widget.onRecipeUnlocked();
                            }
                          }
                        : null,
                    icon: Icon(
                      Icons.lock_open,
                      color: canUnlock ? primaryColor : Colors.grey,
                    ),
                  );
                } else {
                  return Container();
                }
              },
            ),
          IconButton(
            onPressed: () => {
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
                            children: widget.recipe.ingredients!
                                .map(
                                  (ingredient) => Text(
                                    ingredient.name,
                                    style: ShadTheme.of(context).textTheme.p,
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
            icon: const Icon(
              Icons.menu_book,
              color: primaryColor,
            ),
          )
        ],
      ),
      onTap: () {
        widget.isLocked
            ? null
            : {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailsScreen(
                      recipe: widget.recipe,
                    ),
                  ),
                )
              };
      },
    );
  }

  Widget _buildInfoRow({IconData? icon, Widget? widget, required String text}) {
    return Row(
      children: [
        if (icon != null) Icon(icon, color: primaryColor, size: 20),
        if (widget != null) widget,
        const SizedBox(width: 5),
        Text(
          text,
          style: ShadTheme.of(context).textTheme.p,
        ),
      ],
    );
  }
}
