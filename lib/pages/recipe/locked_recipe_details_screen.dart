import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mouvaps/utils/text_utils.dart';
import 'package:mouvaps/services/recipe.dart';
import 'package:mouvaps/utils/constants.dart';

class LockedRecipeDetailsScreen extends StatefulWidget {
  final Recipe recipe;
  final bool isOffline;

  const LockedRecipeDetailsScreen({super.key, required this.recipe, this.isOffline = false});

  @override
  State<LockedRecipeDetailsScreen> createState() => _LockedRecipeDetailsScreenState();
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
            H1(content : widget.recipe.name),
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                const FaIcon(
                  FontAwesomeIcons.lock,
                  color: primaryColor
                ),
                Positioned(
                  bottom: -1,
                  child: BadgeText(
                    content: widget.recipe.pricePoints.toString(),
                    color: lighterColor
                  )
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                double width = constraints.maxWidth; // Get the full width of the page
                return Container(
                  width: width,
                  // Set the height equal to the width - appBar height
                  height: width - kToolbarHeight,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: widget.isOffline
                          ? FileImage(File(widget.recipe.imageUrl))
                          : NetworkImage(widget.recipe.imageUrl),
                      fit: BoxFit.cover, // Ensures the image covers the container
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
                      P(content: widget.recipe.timeMins! >= 60
                          ? '${(widget.recipe.timeMins! ~/ 60)}h${(widget.recipe.timeMins! % 60 > 0 ? ' ${(widget.recipe.timeMins! % 60)} min' : '')}'
                          : '${widget.recipe.timeMins} min'),
                    ],
                  ),
                  Row(
                    children: [
                      const P(content: 'Difficulté : '),
                      StarRating(
                        rating: widget.recipe.difficulty.toDouble(),
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
              child:
                Column(
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
                                      ? FileImage(File(ingredient.imageUrl))
                                      : NetworkImage(ingredient.imageUrl),
                                  fit: BoxFit.contain,
                                  errorBuilder: (BuildContext context, Object exception,
                                      StackTrace? stackTrace) {
                                    return const Icon(
                                      Icons.image_not_supported,
                                      size: 40,
                                    );
                                  },
                                ),
                              ),
                              P(content: ingredient.name),
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
}
