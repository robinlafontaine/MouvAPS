import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mouvaps/services/video.dart';
import 'package:mouvaps/utils/text_utils.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:mouvaps/services/ingredient.dart';
import 'package:mouvaps/services/recipe.dart';
import 'package:mouvaps/utils/constants.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final Recipe recipe;
  final bool isOffline;

  const RecipeDetailsScreen(
      {super.key, required this.recipe, this.isOffline = false});

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  late VideoController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoController(
      videoUrl: widget.recipe.videoUrl,
      isOffline: false,
      autoPlay: false,
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.recipe.name,
          style: ShadTheme.of(context).textTheme.h1,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 200,
                child: Chewie(controller: _videoController.chewieController),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoRow(
                      widget: StarRating(
                        rating: widget.recipe.difficulty.toDouble(),
                        color: primaryColor,
                        emptyIcon: FontAwesomeIcons.star,
                        filledIcon: FontAwesomeIcons.solidStar,
                        halfFilledIcon: FontAwesomeIcons.solidStarHalfStroke,
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
                ],
              ),
              const SizedBox(height: 8),
              const H2(content: "Ingrédients"),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  // Grid axis count based on screen size
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: widget.recipe.ingredients!.length,
                itemBuilder: (context, index) {
                  return _buildIngredientCard(
                      widget.recipe.ingredients![index]);
                },
              ),
              const SizedBox(height: 8),
              Text(
                "Préparation",
                style: ShadTheme.of(context).textTheme.h2,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MarkdownBody(
                  data: widget.recipe.description,
                ),
              ),
            ],
          ),
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

  Widget _buildIngredientCard(Ingredient ingredient) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double imageHeight = deviceWidth / 7;
    return ShadCard(
      padding: const EdgeInsets.all(0),
      title: Center(
        child: Text(
          ingredient.name,
          style: ShadTheme.of(context).textTheme.p,
          softWrap: true,
        ),
      ),
      footer: Center(
        child: Text(
          ingredient.quantity.toString(),
          style: ShadTheme.of(context).textTheme.p,
        ),
      ),
      child: Center(
        child: ClipRRect(
          child: SizedBox(
            height: imageHeight,
            child: Image(
              image: widget.isOffline
                  ? FileImage(File(ingredient.imageUrl))
                  : NetworkImage(ingredient.imageUrl),
              fit: BoxFit.cover,
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                return const Icon(
                  Icons.image_not_supported,
                  size: 30,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
