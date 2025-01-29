import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_rating/flutter_rating.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mouvaps/pages/admin/recipe/ingredient_card_widget.dart';
import 'package:mouvaps/pages/admin/recipe/selectable_list_widget.dart';
import 'package:mouvaps/pages/admin/widgets/upload_file_button.dart';
import 'package:mouvaps/services/recipe.dart';
import 'package:mouvaps/utils/constants.dart';
import 'package:mouvaps/widgets/content_upload_service.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:mouvaps/services/ingredient.dart';
import 'package:mouvaps/utils/text_utils.dart';

class AdminRecipe extends StatefulWidget {
  final Recipe? recipe;

  const AdminRecipe({super.key, this.recipe});

  @override
  State<StatefulWidget> createState() {
    return _AdminRecipeState();
  }
}

class _AdminRecipeState extends State<AdminRecipe> {
  late Recipe _recipe;
  List<String> _steps = [];
  final ContentUploadService _uploadServiceRecipeImage = ContentUploadService(
    directoryPath: "recipes/thumbnails",
    type: FileType.image,
  );
  final ContentUploadService _uploadServiceRecipeVideo = ContentUploadService(
    directoryPath: "recipes/videos",
    type: FileType.video,
  );
  final ContentUploadService _uploadServiceIngredientImage =
      ContentUploadService(
    directoryPath: "ingredients",
    type: FileType.image,
  );

  late Future<List<Ingredient>> _ingredients;

  @override
  void initState() {
    super.initState();
    _ingredients = Ingredient.getAll();
    _recipe = widget.recipe ?? Recipe(difficulty: 0.0, ingredients: []);
    _steps = _recipe.description?.split("\\\n") ?? [];
  }

  void _updateRecipeName(String name) {
    setState(() {
      _recipe.name = name;
    });
  }

  void _addStep(String stepDescription) {
    setState(() {
      _steps.add("**Étape ${_steps.length + 1}**\\\n$stepDescription");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _recipe.name ?? "Nouvelle recette",
          style: ShadTheme.of(context).textTheme.h1,
        ),
      ),
      body: _buildRecipeContent(),
      floatingActionButton: _buildSaveFAB(),
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
            const SizedBox(height: 15),
            _buildRecipeDetails(),
            const H2(content: "Ingrédients"),
            _buildIngredients(),
          ],
        ),
      ),
    );
  }

  Center _buildRecipeImage() {
    return Center(
      child: Column(
        children: [
          if (_recipe.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image(
                  image: _recipe.imageUrl!.contains("https://")
                      ? NetworkImage(_recipe.imageUrl ?? '')
                      : FileImage(File(_recipe.imageUrl ?? '')),
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
            )
          else
            UploadFileButton(
                contentUploadService: _uploadServiceRecipeImage,
                onUpload: () {
                  setState(() {
                    _recipe.imageUrl =
                        _uploadServiceRecipeImage.uploadManager.getFile();
                  });
                })
        ],
      ),
    );
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
      itemCount: (_recipe.ingredients?.length ?? 0) + 1,
      itemBuilder: (context, index) {
        if (_recipe.ingredients != null) {
          if (index == _recipe.ingredients!.length) {
            return _buildAddIngredientCard();
          } else {
            return IngredientCard(
                ingredient: _recipe.ingredients![index],
                isAddIngredient: false);
          }
        }
        return _buildAddIngredientCard();
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
                onPressed: () {
                  // Show the ingredient popup
                  showShadDialog(
                    context: context,
                    builder: (context) {
                      return _buildIngredientPopup();
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIngredientPopup() {
    return ShadDialog(
      constraints: const BoxConstraints(maxWidth: 300),
      radius: BorderRadius.circular(20),
      title: const Text('Ajouter un ingrédient'),
      actions: [
        ShadButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Valider')),
        ShadButton(
            onPressed: () {
              Navigator.of(context).pop();
              showShadDialog(
                  context: context,
                  builder: (context) {
                    return _buildNewIngredientPopup();
                  });
            },
            child: const Text('Ajouter')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        width: 100,
        height: 300,
        child: FutureBuilder(
            future: _ingredients,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return SelectableList(
                    ingredients: snapshot.data as List<Ingredient>,
                    selectedIngredients: _recipe.ingredients ?? [],
                    onIngredientSelected: (ingredient) {
                      setState(() {
                        // Add the ingredient to the recipe if it's name's not already there
                        if (!_recipe.ingredients!.any(
                            (element) => element.name == ingredient.name)) {
                          _recipe.ingredients!.add(ingredient);
                        } else {
                          // Remove the ingredient from the recipe
                          _recipe.ingredients!.removeWhere(
                              (element) => element.name == ingredient.name);
                        }
                      });
                    });
              } else {
                return const SizedBox.shrink();
              }
            }),
      ),
    );
  }

  Widget _buildNewIngredientPopup() {
    return ShadDialog(
      constraints: const BoxConstraints(maxWidth: 300),
      radius: BorderRadius.circular(20),
      title: const Text('Ajouter un ingrédient'),
      actions: const [ShadButton(onPressed: null, child: Text("Ajouter"))],
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        width: 100,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShadButton(
              backgroundColor: Colors.white,
              decoration: const ShadDecoration(
                border: ShadBorder(
                  top: ShadBorderSide(color: primaryColor, width: 2),
                  bottom: ShadBorderSide(color: primaryColor, width: 2),
                  left: ShadBorderSide(color: primaryColor, width: 2),
                  right: ShadBorderSide(color: primaryColor, width: 2),
                ),
              ),
              size: ShadButtonSize.lg,
              child: const Icon(
                FontAwesomeIcons.image,
              ),
              onPressed: () async {
                await _uploadServiceIngredientImage.showUploadDialog(context);
                setState(() {});
              },
            ),
            const SizedBox(height: 10),
            const ShadInput(
              placeholder: Text("Nom de l'ingrédient"),
              keyboardType: TextInputType.text,
            ),
            const ShadInput(
              placeholder: Text("Quantité"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const H2(content: "Détails de la recette"),
        const SizedBox(height: 10),
        _buildRecipeName(),
        const SizedBox(height: 10),
        _buildRecipeDifficulty(),
        const SizedBox(height: 10),
        _buildDescription(),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildRecipeName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const H3(content: "Nom: "),
        ShadInput(
          placeholder: const Text("Nom de la recette"),
          onChanged: _updateRecipeName,
          initialValue: _recipe.name,
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const H3(content: "Description:"),
        const SizedBox(height: 10),
        _buildSteps(),
        const SizedBox(height: 10),
        _buildAddStepButton(),
      ],
    );
  }

  Widget _buildSteps() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _steps.map((step) => MarkdownBody(data: step)).toList(),
    );
  }

  Widget _buildAddStepButton() {
    return Center(
      child: ShadButton(
        backgroundColor: Colors.white,
        decoration: const ShadDecoration(
          border: ShadBorder(
            top: ShadBorderSide(color: primaryColor, width: 2),
            bottom: ShadBorderSide(color: primaryColor, width: 2),
            left: ShadBorderSide(color: primaryColor, width: 2),
            right: ShadBorderSide(color: primaryColor, width: 2),
          ),
        ),
        size: ShadButtonSize.lg,
        child: const Icon(
          FontAwesomeIcons.plus,
        ),
        onPressed: () {
          // Show the ingredient popup
          showShadDialog(
            context: context,
            builder: (context) {
              return _buildAddStepDialog();
            },
          );
        },
      ),
    );
  }

  Widget _buildAddStepDialog() {
    final TextEditingController stepController = TextEditingController();

    return ShadDialog(
      constraints: const BoxConstraints(maxWidth: 300),
      radius: BorderRadius.circular(20),
      title: const Text('Ajouter une étape'),
      actions: [
        ShadButton(
          child: const Text('Ajouter'),
          onPressed: () {
            _addStep(stepController.text);
            Navigator.of(context).pop();
          },
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        width: 100,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShadInput(
              placeholder: const Text("Description de l'étape"),
              keyboardType: TextInputType.text,
              controller: stepController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeDifficulty() {
    return Row(
      children: [
        const H3(content: "Difficulté: "),
        const SizedBox(width: 20),
        StarRating(
          rating: _recipe.difficulty!.toDouble(),
          color: primaryColor,
          emptyIcon: FontAwesomeIcons.star,
          filledIcon: FontAwesomeIcons.solidStar,
          halfFilledIcon: FontAwesomeIcons.solidStarHalfStroke,
          borderColor: primaryColor,
          starCount: 3,
          size: 30,
          allowHalfRating: true,
          onRatingChanged: (rating) {
            setState(() {
              _recipe.difficulty = rating.toDouble();
            });
          },
        ),
        const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildSaveFAB() {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: const BorderSide(color: primaryColor),
      ),
      onPressed: () async {
        if (_recipe.imageUrl != null) {
          await _uploadServiceRecipeImage.startUpload(context).then(
                Navigator.of(context).pop,
              );
        }
      },
      child: const Icon(FontAwesomeIcons.floppyDisk, color: primaryColor),
    );
  }
}
