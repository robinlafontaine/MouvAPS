import 'package:flutter/material.dart';
import 'package:mouvaps/pages/admin/users/user_screen.dart';
import 'package:mouvaps/utils/constants.dart' as constants;
import 'package:mouvaps/utils/text_utils.dart';

class UserTile extends StatelessWidget {
  final String uuid;
  final String firstName;
  final String lastName;
  final int age;

  const UserTile({super.key,
    required this.uuid,
    required this.firstName,
    required this.lastName,
    required this.age,
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
          title: H4(content: "$firstName $lastName" ),
          subtitle: SubTitle(content: "$age ans"),
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