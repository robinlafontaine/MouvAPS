import 'package:flutter/material.dart';
import 'package:mouvaps/pages/admin/users/user_screen.dart';
import 'package:mouvaps/utils/constants.dart' as constants;
import 'package:mouvaps/utils/text_utils.dart';
import 'package:mouvaps/services/user.dart';

class UserTile extends StatelessWidget {
  final User user;

  const UserTile({super.key,
    required this.user,
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
              "${user.firstName[0].toUpperCase()}${user.lastName[0].toUpperCase()}",
              style: const TextStyle(color: constants.primaryColor),
            ),
          ),
          title: H4(content: "${user.firstName} ${user.lastName}"),
          subtitle: SubTitle(content: "${user.age} ans"),
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    UserScreen(uuid: user.userUuid),
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