import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mouvaps/pages/admin/exercise/admin_exercise.dart';
import 'package:mouvaps/services/exercise.dart';
import 'package:mouvaps/services/recipe.dart';
import 'package:mouvaps/utils/constants.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../recipe/admin_recipe.dart';

class ContentListAdmin extends StatefulWidget {
  final List<Recipe>? recipes;
  final List<Exercise>? exercises;

  const ContentListAdmin({super.key, this.recipes, this.exercises});

  @override
  State<StatefulWidget> createState() {
    return _ContentListAdminState();
  }
}

class _ContentListAdminState extends State<ContentListAdmin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBody() {
    // Display a list of exercises
    if (widget.exercises != null && widget.recipes == null) {
      return ListView.separated(
        shrinkWrap: true,
        itemCount: widget.exercises!.length,
        itemBuilder: (context, index) {
          return _buildTitleButton(widget.exercises![index].name, () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AdminExercise(
                  exercise: widget.exercises![index],
                ),
              ),
            );
          });
        },
        separatorBuilder: (context, index) {
          return const Divider(indent: 15, endIndent: 15);
        },
      );
      // Display a list of recipes
    } else if (widget.recipes != null && widget.exercises == null) {
      return ListView.separated(
        shrinkWrap: true,
        itemCount: widget.recipes!.length,
        itemBuilder: (context, index) {
          return _buildTitleButton(widget.recipes![index].name, () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AdminRecipe(
                  recipe: widget.recipes![index],
                ),
              ),
            );
          });
        },
        separatorBuilder: (context, index) {
          return const Divider(indent: 15, endIndent: 15);
        },
      );
    } else if (widget.exercises == null || widget.recipes == null) {
      return const SizedBox.shrink();
    } else {
      return const Center(child: Text('Error'));
    }
  }

  Widget _buildTitleButton(String? title, Function() onPressed) {
    return ListTile(
      title:
          Text(title ?? 'Untitled', style: ShadTheme.of(context).textTheme.p),
      onTap: onPressed,
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: const BorderSide(color: primaryColor),
      ),
      onPressed: () {
        if (widget.exercises != null && widget.recipes == null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AdminExercise(
                newExercise: true,
              ),
            ),
          );
        } else if (widget.recipes != null && widget.exercises == null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AdminRecipe(),
            ),
          );
        } else {}
      },
      child: const Icon(FontAwesomeIcons.plus, color: primaryColor),
    );
  }
}
