import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mouvaps/services/ingredient.dart';

class SelectableList extends StatefulWidget {
  final List<Ingredient> ingredients;
  final List<Ingredient> selectedIngredients;
  final Function(Ingredient) onIngredientSelected;
  const SelectableList(
      {super.key,
      required this.ingredients,
      required this.selectedIngredients,
      required this.onIngredientSelected});

  @override
  State<SelectableList> createState() => _SelectableListState();
}

class _SelectableListState extends State<SelectableList> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: widget.ingredients.length,
      itemBuilder: (context, index) {
        return _buildIngredientCard(widget.ingredients[index]);
      },
      separatorBuilder: (context, index) {
        return const Divider(indent: 15, endIndent: 15);
      },
    );
  }

  Widget _buildIngredientCard(Ingredient ingredient) {
    return Material(
      child: ListTile(
        title: Text(ingredient.name ?? ''),
        trailing: IconButton(
          icon: widget.selectedIngredients.any((selectedIngredient) =>
                  selectedIngredient.name == ingredient.name)
              ? const Icon(FontAwesomeIcons.solidSquareCheck)
              : const Icon(FontAwesomeIcons.square),
          onPressed: () {
            setState(() {
              widget.onIngredientSelected(ingredient);
            });
          },
        ),
      ),
    );
  }
}
