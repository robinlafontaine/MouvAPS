import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mouvaps/utils/text_utils.dart';
import 'package:mouvaps/utils/constants.dart' as constants;
import 'package:mouvaps/services/user.dart';
import 'package:mouvaps/widgets/custom_badge.dart';
import 'package:mouvaps/pages/admin/users/user_edit_screen.dart';

class UserScreen extends StatelessWidget {
  final String uuid;
  final Future<User> user;

  UserScreen({
    super.key,
    required this.uuid,
  }) : user = User.getUserByUuid(uuid);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const H1(content: 'Détails'),
        actions: [
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.solidPenToSquare,
              color: constants.primaryColor
            ),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      UserEditScreen(user: user),
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
            }
          ),
        ],
      ),
      body: Center(
          child: Column(
            children: [
              FutureBuilder(
                  future: user,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    }
                    if (snapshot.hasData) {
                      final User currentUser = snapshot.data;
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: constants.lightColor,
                                  child: Text(
                                    "${currentUser.firstName[0].toUpperCase()}${currentUser.lastName[0].toUpperCase()}",
                                    style: const TextStyle(color: constants.primaryColor),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                BadgeText(content: "${currentUser.firstName} ${currentUser.lastName}"),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(),
                            ),
                            BadgeText(content: "${currentUser.age.toString()} ans"),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(),
                            ),
                            BadgeText(content: "${currentUser.points.toString()} points"),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const BadgeText(content: "Pathologies : "),
                                const SizedBox(height: 5),
                                Flex(
                                  direction: Axis.horizontal,
                                  children: [
                                    for (final pathology in currentUser.pathologies!) ...[
                                      CustomBadge(
                                        text: pathology.name,
                                        backgroundColor: constants.lightColor,
                                        textColor: constants.textColor,
                                      ),
                                      const SizedBox(width: 10)
                                    ],
                                  ],
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const BadgeText(content: "Rôles : "),
                                const SizedBox(height: 5),
                                Flex(
                                  direction: Axis.horizontal,
                                  children: [
                                    if (currentUser.roles == null)
                                      const CustomBadge(
                                        text: "Aucun rôle",
                                        backgroundColor: constants.lightColor,
                                        textColor: constants.textColor,
                                      )
                                    else
                                      for (final role in currentUser.roles!) ...[
                                        CustomBadge(
                                          text: role.name,
                                          backgroundColor: constants.lightColor,
                                          textColor: constants.textColor,
                                        ),
                                        const SizedBox(width: 10)
                                      ]
                                    ,
                                  ],
                                ),
                              ],
                            ),
                          ],

                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }
              )
            ],
          )),
    );
  }
}
