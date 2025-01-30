import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mouvaps/utils/constants.dart';
import 'package:mouvaps/utils/text_utils.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:mouvaps/services/user.dart';
import 'package:mouvaps/services/pathology.dart';
import 'package:mouvaps/services/role.dart';
import 'package:mouvaps/services/difficulty.dart';
import 'package:mouvaps/services/diet.dart';
import 'package:mouvaps/services/allergy.dart';
import 'package:mouvaps/services/home_material.dart';
import 'package:mouvaps/services/diet_expectations.dart';
import 'package:mouvaps/services/sport_expectations.dart';

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
  late User currentUser;

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
              onPressed: () async {
                await currentUser.update();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Modifications enregistrées"),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context);
                }
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
                    currentUser = snapshot.data;
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
                                  onChanged: (value) {
                                    currentUser.firstName = value;
                                  },
                                )
                            ),
                            formElement(
                                label: "Nom",
                                child: ShadInputFormField(
                                  initialValue: currentUser.lastName,
                                  onChanged: (value) {
                                    currentUser.lastName = value;
                                  },
                                )
                            ),
                            formElement(
                                label: "Date de naissance",
                                child: ShadDatePickerFormField(
                                  initialValue: currentUser.birthday,
                                  captionLayout: ShadCalendarCaptionLayout.dropdown,
                                  formatDate: (date) => DateFormat('dd/MM/yyyy').format(date),
                                  validator: (v) {
                                    if (v == null) {
                                      return "Merci d'entrer votre date de naissance";
                                    }
                                    if (v.isAfter(DateTime.now())) {
                                      return "La date de naissance ne peut pas être dans le futur";
                                    }
                                    if (v.isBefore(DateTime.now().subtract(const Duration(days: 365 * 100)))) {
                                      return "La date de naissance ne peut pas être il y a plus de 100 ans";
                                    }
                                    if (v.isAfter(DateTime.now().subtract(const Duration(days: 365 * 18)))) {
                                      return "Vous devez être majeur pour utiliser l'application";
                                    }
                                    currentUser.birthday = v;
                                    return null;
                                  },
                                  allowDeselection: false,
                                  onChanged: (value) {
                                    currentUser.birthday = value!;
                                  },
                                )
                            ),
                            FutureBuilder(
                                future: Difficulty.getAll(),
                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  }
                                  if (snapshot.hasError) {
                                    return Text(snapshot.error.toString());
                                  }
                                  if (snapshot.hasData) {
                                    List<Difficulty> difficulties = snapshot.data;
                                    return formElement(
                                        label: "Niveau",
                                        child: ShadSelect<String>(
                                          minWidth: 340,
                                          maxHeight: 200,
                                          allowDeselection: true,
                                          closeOnSelect: false,
                                          placeholder: const Text("Sélectionnez un niveau"),
                                          options: [
                                            ...difficulties.map(
                                                  (e) => ShadOption(
                                                value: e.name.toString().capitalize(),
                                                child: Text(e.name.toString().capitalize()),
                                              ),
                                            ),
                                          ],
                                          selectedOptionsBuilder: (context,
                                              values) =>
                                              Text(values.map((v) =>
                                                  v.capitalize()).join(', ')),
                                          initialValue: currentUser.difficulty.name.capitalize(),
                                          onChanged: (value) {
                                            currentUser.difficulty = difficulties.firstWhere((e) => e.name.toString().capitalize() == value);
                                          },
                                        )
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }
                            ),
                            futureSelect<Role>(
                              name: "Rôles",
                              placeholder: "Sélectionnez les rôles",
                              futureElements: Role.getAll(),
                              userElements: currentUser.roles,
                            ),
                            futureSelect<Pathology>(
                              name: "Pathologies",
                              placeholder: "Sélectionnez les pathologies",
                              futureElements: Pathology.getAll(),
                              userElements: currentUser.pathologies!,
                            ),
                            futureSelect<Diet>(
                              name: "Régime",
                              placeholder: "Sélectionnez le régime",
                              futureElements: Diet.getAll(),
                              userElements: currentUser.diet,
                            ),
                            futureSelect<Allergy>(
                              name: "Allergies",
                              placeholder: "Sélectionnez les allergies",
                              futureElements: Allergy.getAll(),
                              userElements: currentUser.allergies,
                            ),
                            futureSelect<HomeMaterial>(
                              name: "Matériel sportif",
                              placeholder: "Sélectionnez le matériel sportif",
                              futureElements: HomeMaterial.getAll(),
                              userElements: currentUser.homeMaterial,
                            ),
                            futureSelect<DietExpectations>(
                              name: "Attentes alimentaires",
                              placeholder: "Sélectionnez les attentes alimentaires",
                              futureElements: DietExpectations.getAll(),
                              userElements: currentUser.dietExpectations,
                            ),
                            futureSelect<SportExpectations>(
                              name: "Attentes sportives",
                              placeholder: "Sélectionnez les attentes sportives",
                              futureElements: SportExpectations.getAll(),
                              userElements: currentUser.sportExpectations,
                            ),
                            const SizedBox(height: 200),
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

  Widget futureSelect<T extends dynamic>(
      {required String name, required String placeholder, required Future<List<T>> futureElements, required List<T> userElements}) {
    return FutureBuilder(
        future: futureElements,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          if (snapshot.hasData) {
            List<T> elements = snapshot.data;
            return formElement(
                label: name,
                child: ShadSelect<String>.multiple(
                  minWidth: 340,
                  maxHeight: 200,
                  allowDeselection: true,
                  closeOnSelect: false,
                  placeholder: Text(placeholder),
                  options: [
                    ...elements.map(
                          (e) => ShadOption(
                        value: e.name.toString().capitalize(),
                        child: Text(e.name.toString().capitalize()),
                      ),
                    ),
                  ],
                  selectedOptionsBuilder: (context,
                      values) =>
                      Text(values.map((v) =>
                          v.capitalize()).join(', ')),
                  initialValues: userElements.map((e) => e.name.toString().capitalize()).toList(),
                  onChanged: (values) {
                    userElements.clear();
                    userElements.addAll(values.map((v) => elements.firstWhere((e) => e.name.toString().capitalize() == v)));
                  },
                )
            );
          }
          return const SizedBox.shrink();
        }
    );
  }
}
