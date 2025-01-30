import 'package:flutter/material.dart';
import 'package:mouvaps/services/auth.dart';
import 'package:mouvaps/pages/profile/profile_switch.dart';
import 'package:mouvaps/utils/text_utils.dart';
import 'package:mouvaps/utils/constants.dart' as constants;
import 'package:mouvaps/services/user.dart';
import 'package:mouvaps/widgets/custom_badge.dart';
import 'package:mouvaps/widgets/upload_button.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});
  final Future<bool> hasRole = Auth.instance.hasRole('ADMIN');
  final Future<User> user = User.getUserByUuid(Auth.instance.getUUID());
  final Future<bool> showCertificateUpload = Future.wait([
    Auth.instance.hasCertificate(),
    Auth.instance.needsCertificate()
  ]).then((results) => results[0] && results[1]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const H1(content: 'Profil'),
      ),
      body: Center(
          child: SingleChildScrollView(
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
                          Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              spacing: 10,
                              children: [
                                CircleAvatar(
                                  backgroundColor: constants.lightColor,
                                  radius: 50,
                                  child: Text(
                                    "${currentUser.firstName[0].toUpperCase()}${currentUser.lastName[0].toUpperCase()}",
                                    style: const TextStyle(
                                      color: constants.primaryColor,
                                      fontSize: 30,
                                      fontFamily: constants.fontFamily,
                                      fontVariations: [ FontVariation('wght', 700) ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                H2(content: "${currentUser.firstName} ${currentUser.lastName}"),
                                FutureBuilder<bool>(
                                  future: showCertificateUpload,
                                  builder:
                                      (BuildContext context, AsyncSnapshot<bool> snapshot) {
                                    if (snapshot.hasData && !snapshot.data!) {
                                      return Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: Colors.red[100],
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Certificat médical",
                                              style: TextStyle(
                                                color: Colors.red[700],
                                                fontSize: constants.h4FontSize,
                                                fontFamily: constants.fontFamily,
                                                fontVariations: const [ FontVariation('wght', constants.h4FontWeight) ],
                                              ),
                                            ),
                                            UserUploadButton(
                                              filename: 'certificat',
                                              onUploadComplete: () => (),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: constants.lightColor,
                                  ),
                                  child: Column(
                                    spacing: 0,
                                    children: [
                                      Text(
                                        currentUser.points.toString(),
                                        style: const TextStyle(
                                          color: constants.primaryColor,
                                          fontSize: 70,
                                          fontFamily: constants.fontFamily,
                                          fontVariations: [ FontVariation('wght', 700) ],
                                        ),
                                      ),
                                      const Text(
                                        "pts",
                                        style: TextStyle(
                                          color: constants.textColor,
                                          fontSize: 30,
                                          fontFamily: constants.fontFamily,
                                          fontVariations: [ FontVariation('wght', 700) ],
                                        ),
                                      ),
                                    ],
                                  ),
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
                                ),
                              ],
                            ),
                          ),
                          userElement(
                            label: "Age",
                            child: P(content: "${DateTime.now().difference(currentUser.birthday).inDays ~/ 365} ans"),
                          ),
                          userElement(
                            label: "Genre",
                            child: P(content: currentUser.gender.capitalize()),
                          ),
                          userElement(
                            label: "Points",
                            child: P(content: "${currentUser.points} points"),
                          ),
                          userElement(
                            label: "Niveau",
                            child: P(content: currentUser.difficulty.name.capitalize()),
                          ),
                          badgeElements(label: "Rôles", elements: currentUser.roles),
                          badgeElements(label: "Pathologies", elements: currentUser.pathologies!),
                          badgeElements(label: "Régime", elements: currentUser.diet),
                          badgeElements(label: "Matériel sportif", elements: currentUser.homeMaterial),
                          badgeElements(label: "Allergies", elements: currentUser.allergies),
                          badgeElements(label: "Attentes alimentaires", elements: currentUser.dietExpectations),
                          badgeElements(label: "Attentes sportives", elements: currentUser.sportExpectations),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }
            )
                    ],
                  ),
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

  Widget badgeElements<T extends dynamic>({required String label, required List<T> elements}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        H4(content: label),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: elements.isEmpty
              ? [
            const CustomBadge(
              text: "Inconnu",
              backgroundColor: constants.lightColor,
              textColor: constants.textColor,
            ),
          ]
              : elements
              .map(
                (element) => CustomBadge(
              text: element.name.toString().capitalize(),
              backgroundColor: constants.lightColor,
              textColor: constants.textColor,
            ),
          )
              .toList(),
        ),
      ],
    );
  }
}
