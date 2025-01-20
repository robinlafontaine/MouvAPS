import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mouvaps/pages/recipe/locked_recipe_details_screen.dart';
import 'package:mouvaps/pages/recipe/recipe_details_screen.dart';
import 'package:mouvaps/services/recipe.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:mouvaps/utils/constants.dart';
import 'package:mouvaps/services/user.dart';
import 'package:mouvaps/services/download.dart';
import 'package:mouvaps/widgets/download_button.dart';
import 'package:mouvaps/utils/text_utils.dart';

class RecipeWidget extends StatefulWidget {
  final Recipe recipe;
  final Future<User>? user;
  final bool isLocked;
  final bool isOffline;
  final VoidCallback onRecipeStateChanged;

  const RecipeWidget({
    super.key,
    required this.recipe,
    required this.isLocked,
    this.user,
    this.isOffline = false,
    required this.onRecipeStateChanged,
  });

  @override
  State<StatefulWidget> createState() => _RecipeWidgetState();
}

class _RecipeWidgetState extends State<RecipeWidget> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      enabled: true,
      tileColor: Colors.white,
      leading: _buildRecipeImage(),
      title: _buildRecipeTitle(),
      subtitle: _buildRecipeSubtitle(),
      trailing: !widget.isLocked ? _buildDownloadButton() : null,
      onTap: _handleRecipeTap,
    );
  }

  Widget _buildRecipeImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image(
          image: widget.isOffline
              ? FileImage(File(widget.recipe.imageUrl))
              : NetworkImage(widget.recipe.imageUrl),
          fit: BoxFit.cover,
          errorBuilder:
              (BuildContext context, Object exception, StackTrace? stackTrace) {
            return const Icon(
              Icons.image_not_supported,
              size: 30,
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
    return widget.isLocked
        ? P(content: '${widget.recipe.pricePoints} points')
        : _buildDurationInfo();
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

  Widget _buildDownloadButton() {
    return DownloadButton<Recipe>(
      item: widget.recipe,
      itemId: widget.recipe.id!,
      isEnabled: !widget.isLocked && !widget.isOffline,
      downloadRequests: [
        DownloadRequest(
          url: widget.recipe.imageUrl,
          filename: 'r_${widget.recipe.name}_i',
          fileExtension: widget.recipe.imageUrl.split('.').last,
        ),
        DownloadRequest(
          url: widget.recipe.videoUrl,
          filename: 'r_${widget.recipe.name}_v',
          fileExtension: widget.recipe.videoUrl.split('.').last,
        ),
        ...widget.recipe.ingredients!.map((ingredient) => DownloadRequest(
              url: ingredient.imageUrl,
              filename: 'ing_${ingredient.name}',
              fileExtension: ingredient.imageUrl.split('.').last,
            )),
      ],
      onSave: (paths) async {
        await Recipe.saveLocalRecipe(
            widget.recipe, paths[1], paths[0], paths.sublist(2));
      },
      onDownloadComplete: (recipe) {
        if (!mounted) return;
        setState(() {});
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

  void _handleRecipeTap() {
    if (!widget.isLocked) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => RecipeDetailsScreen(
            recipe: widget.recipe,
            isOffline: widget.isOffline,
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => LockedRecipeDetailsScreen(
            recipe: widget.recipe,
            isOffline: widget.isOffline,
            user: widget.user,
            onRecipeStateChanged: widget.onRecipeStateChanged,
          ),
        ),
      );
    }
  }
}
