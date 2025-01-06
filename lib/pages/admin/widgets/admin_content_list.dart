import 'package:flutter/material.dart';
import 'package:mouvaps/pages/admin/widgets/admin_content_new.dart';
import 'package:mouvaps/services/exercise.dart';
import 'package:mouvaps/services/recipe.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
    if (widget.exercises != null && widget.recipes == null) {
      return ListView.separated(
        shrinkWrap: true,
        itemCount: widget.exercises!.length,
        itemBuilder: (context, index) {
          return _buildTitleButton(widget.exercises![index].name, () {});
        },
        separatorBuilder: (context, index) {
          return const Divider(indent: 15, endIndent: 15);
        },
      );
    } else if (widget.recipes != null && widget.exercises == null) {
      return ListView.separated(
        shrinkWrap: true,
        itemCount: widget.recipes!.length,
        itemBuilder: (context, index) {
          return _buildTitleButton(widget.recipes![index].name, () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AdminNewContent(),
              ),
            );
          });
        },
        separatorBuilder: (context, index) {
          return const Divider(indent: 15, endIndent: 15);
        },
      );
    } else if (widget.exercises == null || widget.recipes == null) {
      return const CircularProgressIndicator();
    } else {
      return const Center(child: Text('Error'));
    }
  }

  Widget _buildTitleButton(String title, Function() onPressed) {
    return ListTile(
      title: Text(title, style: ShadTheme.of(context).textTheme.p),
      onTap: onPressed,
    );
  }
}
