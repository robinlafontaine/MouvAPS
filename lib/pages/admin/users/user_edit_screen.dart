import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mouvaps/utils/constants.dart';
import 'package:mouvaps/utils/text_utils.dart';
import 'package:mouvaps/services/user.dart';
import 'package:mouvaps/services/pathology.dart';
import 'package:mouvaps/services/role.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class UserEditScreen extends StatefulWidget {
  final Future<User> user;
  final Future<List<Pathology>> pathologies = Pathology.getAll();
  final Future<List<Role>> roles = Role.getAll();

  UserEditScreen({
    super.key,
    required this.user,
  });

  @override
  State<UserEditScreen> createState() => _UserEditScreenState();
}

class _UserEditScreenState extends State<UserEditScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const H1(content: 'Modifications'),
        actions: [
          IconButton(
            icon: const FaIcon(
                FontAwesomeIcons.solidFloppyDisk,
                color: primaryColor
            ),
            onPressed: () {
            }
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder(
                future: widget.user,
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
                      child: ShadForm(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            formElement(
                                label: "Prénom",
                                child: ShadInputFormField(
                                  initialValue: currentUser.firstName,
                                )
                            ),
                            formElement(
                                label: "Nom",
                                child: ShadInputFormField(
                                  initialValue: currentUser.lastName,
                                )
                            ),
                            formElement(
                                label: "Date de naissance",
                                child: ShadDatePickerFormField(
                                  initialValue: DateTime(2000),
                                )
                            ),
                            FutureBuilder(
                                future: widget.roles,
                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  }
                                  if (snapshot.hasError) {
                                    return Text(snapshot.error.toString());
                                  }
                                  if (snapshot.hasData) {
                                    List<Role> roles = snapshot.data;
                                    return formElement(
                                        label: "Rôles",
                                        child: ShadSelect<String>.multiple(
                                          minWidth: 340,
                                          allowDeselection: true,
                                          closeOnSelect: false,
                                          placeholder: const Text(
                                              'Sélectionnez les rôles'),
                                          options: [
                                            ...roles.map(
                                                  (e) => ShadOption(
                                                value: e.id.toString(),
                                                child: Text(e.name),
                                              ),
                                            ),
                                          ],
                                          selectedOptionsBuilder: (context,
                                              values) =>
                                              Text(values.map((v) =>
                                                  v.capitalize()).join(', ')),
                                          initialValues: currentUser.roles.map((e) => e.id.toString()).toList(),
                                        )
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }
                            ),
                            FutureBuilder(
                              future: widget.pathologies,
                              builder: (BuildContext context, AsyncSnapshot snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                if (snapshot.hasError) {
                                  return Text(snapshot.error.toString());
                                }
                                if (snapshot.hasData) {
                                  List<Pathology> pathologies = snapshot.data;
                                  return formElement(
                                    label: "Pathologies",
                                    child: ShadSelect<String>.multiple(
                                      minWidth: 340,
                                      allowDeselection: true,
                                      closeOnSelect: false,
                                      placeholder: const Text(
                                          'Sélectionnez les pathologies'),
                                      options: [
                                        ...pathologies.map(
                                              (e) => ShadOption(
                                            value: e.id.toString(),
                                            child: Text(e.name),
                                          ),
                                        ),
                                      ],
                                      selectedOptionsBuilder: (context,
                                          values) =>
                                          Text(values.map((v) =>
                                              v.capitalize()).join(', ')),
                                      initialValues: currentUser.pathologies!.map((e) => e.id.toString()).toList(),
                                    )
                                  );
                                }
                                return const SizedBox.shrink();
                              }
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }
            )
          ],
        ),
      ),
    );
  }

  Widget formElement({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        H4(content: label),
        child,
        const Divider(),
      ],
    );
  }
}
