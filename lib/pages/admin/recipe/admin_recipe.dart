import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mouvaps/services/recipe.dart';
import 'package:mouvaps/utils/constants.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../services/ingredient.dart';

class AdminRecipe extends StatefulWidget {
  final Recipe? recipe;
  final bool? newRecipe;

  const AdminRecipe({super.key, this.recipe, this.newRecipe})
      : assert(recipe != null || newRecipe != null,
            'recipe or newRecipe must be provided');

  @override
  State<StatefulWidget> createState() {
    return _AdminRecipeState();
  }
}

class _AdminRecipeState extends State<AdminRecipe> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.recipe != null ? widget.recipe!.name : 'New Recipe',
          style: ShadTheme.of(context).textTheme.h1,
        ),
      ),
      body: _buildRecipeContent(),
    );
  }

  Widget _buildRecipeContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRecipeImage(),
            const SizedBox(height: 15),
            _buildRecipeVideo(),
            _buildIngredients(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeImage() {
    return const Center(child: Text("TODO - Recipe Placeholder"));
    /*ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image(
          image: widget.recipe != null
              ? NetworkImage(widget.recipe!.imageUrl)
              : const AssetImage('assets/images/default_recipe_image.png'),
          fit: BoxFit.cover,
          errorBuilder:
              (BuildContext context, Object exception, StackTrace? stackTrace) {
            return Image.asset('assets/images/placeholder.png');
          },
        ),
      ),
    );*/
  }

  Widget _buildRecipeVideo() {
    return const Center(child: Text("TODO - Recipe Video"));
  }

  Widget _buildIngredients() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: (widget.recipe?.ingredients?.length ?? 0) + 1,
      itemBuilder: (context, index) {
        if (index == widget.recipe?.ingredients?.length) {
          return _buildAddIngredientCard();
        } else {
          return _buildIngredientCard(widget.recipe?.ingredients![index]);
        }
      },
    );
  }

  Widget _buildAddIngredientCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double iconSize =
            constraints.maxHeight / 3; // Adjust the size as needed
        return ShadCard(
          padding: const EdgeInsets.all(0),
          child: Expanded(
            child: Center(
              child: IconButton(
                icon: Icon(
                  FontAwesomeIcons.plus,
                  color: primaryColor,
                  size: iconSize,
                ),
                onPressed: () {},
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIngredientCard(Ingredient? ingredient) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double imageHeight = deviceWidth / 7;
    return ShadCard(
      padding: const EdgeInsets.all(0),
      title: Center(
        child: Text(
          ingredient!.name,
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
}
