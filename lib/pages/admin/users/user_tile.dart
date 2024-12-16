import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:mouvaps/utils/constants.dart';

class UserTile extends StatelessWidget {
  final String firstName;
  final String lastName;
  final int points;
  final int age;

  const UserTile({super.key,
    required this.firstName,
    required this.lastName,
    required this.points,
    required this.age,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child:
        ColoredBox(
          color: lightColor,
          child:
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child:ListTile(
                    title: Text(
                      '$firstName $lastName',
                        style: ShadTheme.of(context).textTheme.h3
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Points: $points'),
                        Text('Age: $age'),
                      ],
                    ),
                  ),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
              ],
            ),
        ),
    );
  }
}