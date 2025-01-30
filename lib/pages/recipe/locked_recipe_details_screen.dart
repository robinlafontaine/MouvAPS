import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mouvaps/services/user.dart';
import 'package:mouvaps/utils/text_utils.dart';
import 'package:mouvaps/services/recipe.dart';
import 'package:mouvaps/utils/constants.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../notifiers/user_points_notifier.dart';

class LockedRecipeDetailsScreen extends StatefulWidget {
  final Recipe recipe;
  final bool isOffline;
  final Future<User>? user;
  final VoidCallback onRecipeStateChanged;

  const LockedRecipeDetailsScreen(
      {super.key,
      required this.recipe,
      this.isOffline = false,
      this.user,
      required this.onRecipeStateChanged});

  @override
  State<LockedRecipeDetailsScreen> createState() =>
      _LockedRecipeDetailsScreenState();
}

class _LockedRecipeDetailsScreenState extends State<LockedRecipeDetailsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: Text(
                widget.recipe.name ?? 'Pas de nom',
                style: ShadTheme.of(context).textTheme.h1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _buildUnlockButton(),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                double width =
                    constraints.maxWidth; // Get the full width of the page
                return Container(
                  width: width,
                  // Set the height equal to the width - appBar height
                  height: width - kToolbarHeight,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: widget.isOffline
                          ? FileImage(File(widget.recipe.imageUrl ?? ''))
                          : NetworkImage(widget.recipe.imageUrl ?? ''),
                      fit: BoxFit
                          .cover, // Ensures the image covers the container
                      alignment: Alignment.center,
                    ),
                  ),
                );
              },
            ),
            Container(
              color: lightColor,
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      const P(content: "Durée : "),
                      P(
                          content: widget.recipe.timeMins! >= 60
                              ? '${(widget.recipe.timeMins! ~/ 60)}h${(widget.recipe.timeMins! % 60 > 0 ? ' ${(widget.recipe.timeMins! % 60)} min' : '')}'
                              : '${widget.recipe.timeMins} min'),
                    ],
                  ),
                  Row(
                    children: [
                      const P(content: 'Difficulté : '),
                      StarRating(
                        rating: widget.recipe.difficulty!.toDouble(),
                        color: primaryColor,
                        emptyIcon: FontAwesomeIcons.star,
                        filledIcon: FontAwesomeIcons.solidStar,
                        halfFilledIcon: FontAwesomeIcons.solidStarHalfStroke,
                        borderColor: primaryColor,
                        starCount: 3,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const H2(content: 'Ingrédients'),
                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      for (final ingredient in widget.recipe.ingredients!) ...[
                        Row(
                          spacing: 10,
                          children: [
                            SizedBox(
                              width: 40,
                              height: 40,
                              child: Image(
                                image: widget.isOffline
                                    ? FileImage(File(ingredient.imageUrl ?? ''))
                                    : NetworkImage(ingredient.imageUrl ?? ''),
                                fit: BoxFit.contain,
                                errorBuilder: (BuildContext context,
                                    Object exception, StackTrace? stackTrace) {
                                  return const Icon(
                                    Icons.image_not_supported,
                                    size: 40,
                                  );
                                },
                              ),
                            ),
                            P(content: ingredient.name ?? ''),
                          ],
                        ),
                      ],
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnlockButton() {
    if (widget.user == null) {
      return const CircularProgressIndicator();
    }
    return FutureBuilder<User>(
      future: widget.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          return _buildUnlockButtonContent(snapshot.data!);
        }
        return Container();
      },
    );
  }

  Widget _buildUnlockButtonContent(User userData) {
    if (userData == User.empty()) {
      return const SizedBox();
    }
    bool canUnlock = userData.points >= (widget.recipe.pricePoints ?? 0);
    return IconButton(
        onPressed: canUnlock ? () => _handleUnlock(userData) : null,
        icon: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            const FaIcon(FontAwesomeIcons.lock, color: primaryColor),
            Positioned(
                bottom: -1,
                child: BadgeText(
                    content: widget.recipe.pricePoints.toString(),
                    color: lighterColor)),
          ],
        ));
  }

  Future<void> _handleUnlock(User userData) async {
    if (userData == User.empty()) {
      return;
    }
    bool? result = await _showUnlockConfirmationDialog();
    if (result == true) {
      await _processUnlock(userData);
    }
  }

  Future<bool?> _showUnlockConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        elevation: 5.0,
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Déverrouiller ${widget.recipe.name} pour ${widget.recipe.pricePoints} pts ?',
                style: ShadTheme.of(context).textTheme.p,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildUnlockDialogButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnlockDialogButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ShadButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Oui'),
        ),
        ShadButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
      ],
    );
  }

  Future<void> _processUnlock(User userData) async {
    // Unlock the recipe
    await widget.recipe.unlockRecipe(userData.userUuid);
    if (!mounted) return;
    // Add the points to the user
    Provider.of<UserPointsNotifier>(context, listen: false)
        .decrementPoints(widget.recipe.pricePoints ?? 0);
    // Go back to the previous screen and refresh the state
    Navigator.pop(context);
    widget.onRecipeStateChanged();
  }
}
