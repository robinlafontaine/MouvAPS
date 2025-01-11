import 'package:flutter/material.dart';
import 'package:mouvaps/services/auth.dart';
import 'package:mouvaps/pages/profile/profile_switch.dart';
import 'package:mouvaps/utils/text_utils.dart';
import 'package:mouvaps/utils/constants.dart' as constants;
import 'package:mouvaps/services/user.dart';
import 'package:mouvaps/widgets/custom_badge.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});
  final Future<bool> hasRole = Auth.instance.hasRole('ADMIN');
  final Future<User> user = User.getUserByUuid(Auth.instance.getUUID());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const H1(content: 'Profil'),
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
                            BadgeText(content: "${currentUser.firstName}${currentUser.lastName}"),
                          ],
                        ),
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
                        FutureBuilder<bool>(
                          future: hasRole,
                          builder:
                              (BuildContext context, AsyncSnapshot<bool> snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            if (snapshot.hasError) {
                              return Text(snapshot.error.toString());
                            }
                            if (snapshot.data == true) {
                              return const ProfileSwitch();
                            }
                            return const SizedBox.shrink();
                          },
                        )
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
