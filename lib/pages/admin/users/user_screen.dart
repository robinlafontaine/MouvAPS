import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mouvaps/utils/text_utils.dart';
import 'package:mouvaps/utils/constants.dart' as constants;
import 'package:mouvaps/services/user.dart';
import 'package:mouvaps/widgets/certificate_button.dart';
import 'package:mouvaps/widgets/custom_badge.dart';
import 'package:mouvaps/pages/admin/users/user_edit_screen.dart';

class UserScreen extends StatefulWidget {
  final String uuid;

  const UserScreen({super.key, required this.uuid});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  late Future<User> user;

  @override
  void initState() {
    super.initState();
    user = User.getUserByUuid(widget.uuid);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      user = User.getUserByUuid(widget.uuid); // Reload data when page is revisited
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const H1(content: 'Détails'),
        actions: [
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.solidPenToSquare,
              color: constants.primaryColor,
            ),
            onPressed: () async {
              await Navigator.push(
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
              setState(() {
                user = User.getUserByUuid(widget.uuid); // Reload user after editing
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: user,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }
            if (snapshot.hasData) {
              final User currentUser = snapshot.data;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                    const SizedBox(height: 20),
                    Center(child: CertificateButton(user: currentUser)),
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
          },
        ),
      ),
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
