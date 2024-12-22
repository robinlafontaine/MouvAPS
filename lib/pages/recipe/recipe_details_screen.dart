import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:mouvaps/services/video.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../services/ingredient.dart';
import '../../services/recipe.dart';
import '../../utils/constants.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailsScreen({super.key, required this.recipe});

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
        title:
            Text(widget.recipe.name, style: ShadTheme.of(context).textTheme.h1),
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
              const SizedBox(height: 8),
              Text(
                "Ingrédients",
                style: ShadTheme.of(context).textTheme.h2,
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                child: MarkdownBody(data: widget.recipe.description),
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
    return ShadCard(
      padding: const EdgeInsets.all(3),
      title: Center(
        child: Text(
          ingredient.name,
          style: ShadTheme.of(context).textTheme.h3,
          softWrap: true,
        ),
      ),
      footer: Center(
        child: Text(
          ingredient.quantity.toString(),
          style: ShadTheme.of(context).textTheme.p,
        ),
      ),
      child: ClipRRect(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image(
            image: NetworkImage(ingredient.imageUrl),
            fit: BoxFit.contain,
            errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
              return Image.asset(
                'assets/images/default_exercise_image.jpg',
                fit: BoxFit.contain,
              );
            },
          ),
        ),
      ),
    );
  }
}
