import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mouvaps/services/ingredient.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class IngredientCard extends StatefulWidget {
  final Ingredient ingredient;
  final bool isAddIngredient;
  final VoidCallback onRemove;

  const IngredientCard({
    super.key,
    required this.ingredient,
    required this.isAddIngredient,
    required this.onRemove,
  });

  @override
  State createState() => _IngredientCardState();
}

class _IngredientCardState extends State<IngredientCard> {
  @override
  Widget build(BuildContext context) {
    if (widget.isAddIngredient) {
      return _buildAddIngredientCard(context);
    } else {
      return _buildIngredientCard(context);
    }
  }

  Widget _buildIngredientCard(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double imageHeight = deviceWidth / 7;
    return InkWell(
      onTap: () {
        _buildIngredientPopup(context);
      },
      child: ShadCard(
        padding: const EdgeInsets.all(0),
        title: Center(
          child: Text(
            widget.ingredient.name ?? '',
            style: ShadTheme.of(context).textTheme.p,
            softWrap: true,
          ),
        ),
        footer: Center(
          child: Text(
            widget.ingredient.quantity.toString(),
            style: ShadTheme.of(context).textTheme.p,
          ),
        ),
        child: Center(
          child: ClipRRect(
            child: SizedBox(
              height: imageHeight,
              child: Image(
                image: NetworkImage(widget.ingredient.imageUrl ?? ''),
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
      ),
    );
  }

  Widget _buildAddIngredientCard(BuildContext context) {
    return const Text("TODO");
  }

  Future _buildIngredientPopup(BuildContext context) {
    return showShadDialog(
      context: context,
      builder: (BuildContext context) {
        return ShadDialog(
          constraints: const BoxConstraints(maxWidth: 300),
          title: Text(widget.ingredient.name ?? ''),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fermer'),
            ),
            IconButton(
                icon: const Icon(FontAwesomeIcons.trash, color: Colors.red),
                onPressed: () {
                  widget.onRemove();
                  Navigator.of(context).pop();
                }),
          ],
          child: Column(
            children: <Widget>[
              Image(
                image: NetworkImage(widget.ingredient.imageUrl ?? ''),
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return const Icon(
                    Icons.image_not_supported,
                    size: 30,
                  );
                },
              ),
              const SizedBox(height: 10),
              ShadInput(
                placeholder: const Text('Quantité'),
                initialValue: widget.ingredient.quantity.toString(),
                keyboardType: TextInputType.number,
                onChanged: (String value) {
                  setState(() {
                    widget.ingredient.quantity = int.parse(value);
                  });
                },
              )
            ],
          ),
        );
      },
    );
  }
}
