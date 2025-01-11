import 'package:flutter/material.dart';
import 'package:mouvaps/pages/admin/users/user_screen.dart';
import 'package:mouvaps/utils/constants.dart' as constants;
import 'package:mouvaps/utils/text_utils.dart';
import 'package:mouvaps/widgets/custom_badge.dart';
import 'package:mouvaps/services/pathology.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class UserTile extends StatelessWidget {
  final String uuid;
  final String firstName;
  final String lastName;
  final int age;
  final List<Pathology>? pathologies;

  const UserTile({super.key,
    required this.uuid,
    required this.firstName,
    required this.lastName,
    required this.age,
    this.pathologies = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: constants.lightColor,
            child: Text(
              "${firstName[0].toUpperCase()}${lastName[0].toUpperCase()}",
              style: const TextStyle(color: constants.primaryColor),
            ),
          ),
          title: BadgeText(content: "$firstName $lastName"),
          subtitle: Wrap(
            spacing: 10,
            runSpacing: 5, // Adds spacing between rows if wrapping occurs
            children: [
              CustomBadge(
                  text: "$age ans",
                  backgroundColor: constants.primaryColor,
                  textColor: constants.lightColor,
              ),
              for (final pathology in pathologies!) ...[
                CustomBadge(
                    text: pathology.name,
                    backgroundColor: constants.lightColor,
                    textColor: constants.textColor,
                ),
              ],
            ],
          ),
          trailing: IconButton(
              onPressed: () {},
              icon: Icon(PhosphorIcons.pencilSimple(PhosphorIconsStyle.regular))),
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    UserScreen(uuid: uuid),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  var begin = const Offset(1.0, 0.0);
                  var end = Offset.zero;
                  var curve = Curves.ease;

                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              ),
            );
          },
        ),

        const Divider(),
      ],
    );
  }

}