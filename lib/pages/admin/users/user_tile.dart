import 'package:flutter/material.dart';
import 'package:mouvaps/utils/constants.dart' as constants;
import 'package:mouvaps/utils/text_utils.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:mouvaps/services/pathology.dart';

class UserTile extends StatelessWidget {
  final String firstName;
  final String lastName;
  final int points;
  final int age;
  final List<Pathology>? pathologies;

  const UserTile({super.key,
    required this.firstName,
    required this.lastName,
    required this.points,
    required this.age,
    required this.pathologies,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flex(
              direction: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: constants.lightColor,
                  child: Text(
                    "${firstName[0].toUpperCase()}${lastName[0].toUpperCase()}",
                    style: const TextStyle(color: constants.primaryColor),
                  ),
                ),
                const SizedBox(width: 10),
                MediumText(content: "$firstName $lastName ($age ans)"),
              ],
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
          ],
        ),
        Text("$points points"),
        Flex(
          direction: Axis.horizontal,
          children: [
            for (final pathology in pathologies!) ...[
              ShadBadge(child: Text(pathology.name)),
              const SizedBox(width: 10)
            ],
          ],
        ),

        const Divider(),
      ],
    );
  }
}