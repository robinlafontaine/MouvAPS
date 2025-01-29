import 'package:flutter/material.dart';

import 'package:mouvaps/services/ingredient.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class IngredientCard extends StatelessWidget {
  final Ingredient ingredient;
  final bool isAddIngredient;

  const IngredientCard(
      {super.key, required this.ingredient, required this.isAddIngredient});

  @override
  Widget build(BuildContext context) {
    if (isAddIngredient) {
      return _buildAddIngredientCard(context);
    } else {
      return _buildIngredientCard(context);
    }
  }

  Widget _buildIngredientCard(BuildContext context) {
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
              image: NetworkImage(ingredient.imageUrl),
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

  Widget _buildAddIngredientCard(BuildContext context) {
    return const Text("TODO");
  }
}
