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
      body: SingleChildScrollView(
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
                                H4(content: "${currentUser.firstName} ${currentUser.lastName}"),
                              ],
                            ),
                            userElement(
                              label: "Age",
                              child: P(content: "${DateTime.now().difference(currentUser.birthday).inDays ~/ 365 } ans")
                            ),
                            userElement(
                                label: "Genre",
                                child: P(content: currentUser.gender)
                            ),
                            userElement(
                              label: "Points",
                              child: P(content: "${currentUser.points.toString()} points")
                            ),
                            userElement(
                              label: "Rôles",
                              child: Flex(
                                direction: Axis.horizontal,
                                children: [
                                  if (currentUser.roles.isEmpty) ...[
                                    const CustomBadge(
                                      text: "EN ATTENTE",
                                      backgroundColor: constants.lightColor,
                                      textColor: constants.textColor,
                                    ),
                                    const SizedBox(width: 10)
                                  ] else
                                  for (final role in currentUser.roles) ...[
                                    CustomBadge(
                                      text: role.name,
                                      backgroundColor: constants.lightColor,
                                      textColor: constants.textColor,
                                    ),
                                    const SizedBox(width: 10)
                                  ]
                                ],
                              )
                            ),
                            badgeElements(
                                label: "Pathologies",
                                elements: currentUser.pathologies!
                            ),
                            badgeElements(
                                label: "Régime",
                                elements: currentUser.regimesAlimentaires
                            ),
                            badgeElements(
                              label: "Matériel sportif",
                              elements: currentUser.materielSportif
                            ),
                            badgeElements(
                                label: "Allergies",
                                elements: currentUser.allergies
                            ),
                            badgeElements(
                                label: "Attentes alimentaires",
                                elements: currentUser.attentesAlimentaires
                            ),badgeElements(
                                label: "Attentes sportives",
                                elements: currentUser.attentesSportives
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

  Widget userElement({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        H4(content: label),
        child,
      ],
    );
  }

  Widget badgeElements<T extends dynamic>(
      {required String label, required List<T> elements}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        H4(content: label),
        Flex(
          direction: Axis.horizontal,
          children: [
            if (elements.isEmpty) ...[
              const CustomBadge(
                text: "Inconnu",
                backgroundColor: constants.lightColor,
                textColor: constants.textColor,
              ),
              const SizedBox(width: 10)
            ] else
            for (final element in elements) ...[
              CustomBadge(
                text: element.name,
                backgroundColor: constants.lightColor,
                textColor: constants.textColor,
              ),
              const SizedBox(width: 10)
            ],
          ],
        ),
      ],
    );
  }
}
