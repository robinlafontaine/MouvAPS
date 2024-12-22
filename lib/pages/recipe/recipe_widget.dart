import 'dart:core';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:mouvaps/pages/recipe/recipe_details_screen.dart';
import 'package:mouvaps/pages/recipe/recipe_download.dart';
import 'package:mouvaps/services/recipe.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:mouvaps/utils/constants.dart';
import 'package:mouvaps/services/user.dart';
import 'package:mouvaps/notifiers/user_points_notifier.dart';

class RecipeWidget extends StatefulWidget {
  final Recipe recipe;
  final Future<User>? user;
  final bool isLocked;
  final bool isOffline;
  final VoidCallback onRecipeUnlocked;

  const RecipeWidget({
    super.key,
    required this.recipe,
    required this.isLocked,
    this.user,
    this.isOffline = false,
    required this.onRecipeUnlocked,
  });

  @override
  State<StatefulWidget> createState() => _RecipeWidgetState();
}

class _RecipeWidgetState extends State<RecipeWidget> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      enabled: !widget.isLocked,
      tileColor: Colors.white,
      leading: _buildRecipeImage(),
      title: _buildRecipeTitle(),
      subtitle: _buildRecipeSubtitle(),
      trailing: _buildTrailingButtons(),
      onTap: _handleRecipeTap,
    );
  }

  Widget _buildRecipeImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image(
          image: NetworkImage(widget.recipe.imageUrl),
          fit: BoxFit.cover,
          errorBuilder:
              (BuildContext context, Object exception, StackTrace? stackTrace) {
            return Image.asset(
              'assets/images/default_exercise_image.jpg',
              fit: BoxFit.cover,
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecipeTitle() {
    return Text(
      widget.recipe.name,
      style: ShadTheme.of(context).textTheme.h3,
    );
  }

  Widget _buildRecipeSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDifficultyRating(),
        _buildDurationInfo(),
        _buildPointsInfo(),
      ],
    );
  }

  Widget _buildDifficultyRating() {
    return _buildInfoRow(
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
        text: "Difficulté");
  }

  Widget _buildDurationInfo() {
    String duration = widget.recipe.timeMins! >= 60
        ? '${(widget.recipe.timeMins! ~/ 60)}h${(widget.recipe.timeMins! % 60 > 0 ? ' ${(widget.recipe.timeMins! % 60)} min' : '')}'
        : '${widget.recipe.timeMins} min';
    return _buildInfoRow(
      icon: Icons.timer,
      text: duration,
    );
  }

  Widget _buildPointsInfo() {
    return _buildInfoRow(
      icon: Icons.payments,
      text: '${widget.recipe.pricePoints} points',
    );
  }

  Widget _buildTrailingButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.isLocked) _buildUnlockButton(),
        if (widget.isLocked) _ingredientButton(),
        if (!widget.isOffline && !widget.isLocked) _buildDownloadButton(),
        if (widget.isOffline) _buildOfflineIndicator(),
      ],
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
      icon: Icon(
        Icons.lock_open,
        color: canUnlock ? primaryColor : Colors.grey,
      ),
    );
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
      builder: (BuildContext context) => _buildUnlockDialog(),
    );
  }

  Widget _buildUnlockDialog() {
    return Dialog(
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
    await widget.recipe.unlockRecipe(userData.userUuid);
    await userData
        .updatePoints(userData.points - (widget.recipe.pricePoints ?? 0));
    if (!mounted) return;
    Provider.of<UserPointsNotifier>(context, listen: false)
        .addPoints(-(widget.recipe.pricePoints ?? 0));
    widget.onRecipeUnlocked();
  }

  Widget _buildDownloadButton() {
    return RecipeDownloadButton(
      recipe: widget.recipe,
      onDownloadComplete: (Recipe recipe) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recette téléchargée !')),
        );
      },
    );
  }

  Widget _buildOfflineIndicator() {
    return const IconButton(
      onPressed: null,
      icon: Icon(
        Icons.check_circle_outlined,
        color: primaryColor,
      ),
    );
  }

  Widget _ingredientButton() {
    return IconButton(
      onPressed: _showIngredientsDialog,
      icon: const Icon(
        Icons.menu_book,
        color: primaryColor,
      ),
    );
  }

  void _showIngredientsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => _buildIngredientsDialog(),
    );
  }

  Widget _buildIngredientsDialog() {
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
                  .map((ingredient) => Text(
                        ingredient.name,
                        style: ShadTheme.of(context).textTheme.p,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
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

  void _handleRecipeTap() {
    if (!widget.isLocked) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RecipeDetailsScreen(
            recipe: widget.recipe,
          ),
        ),
      );
    }
  }
}
