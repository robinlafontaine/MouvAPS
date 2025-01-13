import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mouvaps/utils/constants.dart';
import 'package:mouvaps/utils/text_utils.dart';
import 'package:mouvaps/services/user.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

final rolesList = {
  '1': 'ADMIN',
  '2': 'VERIFIED',
  '3': 'PENDING',
};

final pathologiesList = {
  '1': 'n/a',
  '2': 'obésité',
  '3': 'maladie cardiaque',
};

class UserEditScreen extends StatefulWidget {
  final Future<User> user;

  const UserEditScreen({
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
      body: Center(
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
                              _FormElement(
                                  label: "Prénom",
                                  child: ShadInputFormField(
                                    initialValue: currentUser.firstName,
                                  )
                              ),
                              _FormElement(
                                  label: "Nom",
                                  child: ShadInputFormField(
                                    initialValue: currentUser.lastName,
                                  )
                              ),
                              _FormElement(
                                  label: "Date de naissance",
                                  child: ShadDatePickerFormField(
                                    initialValue: DateTime(2000),
                                  )
                              ),
                              _FormElement(
                                  label: "Rôles",
                                  child: ShadSelect<String>.multiple(
                                    minWidth: 340,
                                    onChanged: print,
                                    allowDeselection: true,
                                    closeOnSelect: false,
                                    placeholder: const Text('Sélectionnez les rôles'),
                                    options: [
                                      ...rolesList.entries.map(
                                            (e) => ShadOption(
                                          value: e.key,
                                          child: Text(e.value),
                                        ),
                                      ),
                                    ],
                                    selectedOptionsBuilder: (context, values) =>
                                        Text(values.map((v) => v.capitalize()).join(', ')),
                                  )
                              ),
                              _FormElement(
                                  label: "Pathologies",
                                  child: ShadSelect<String>.multiple(
                                    minWidth: 340,
                                    onChanged: print,
                                    allowDeselection: true,
                                    closeOnSelect: false,
                                    placeholder: const Text('Sélectionnez les pathologies'),
                                    options: [
                                      ...pathologiesList.entries.map(
                                            (e) => ShadOption(
                                          value: e.key,
                                          child: Text(e.value),
                                        ),
                                      ),
                                    ],
                                    selectedOptionsBuilder: (context, values) =>
                                        Text(values.map((v) => v.capitalize()).join(', ')),
                                  )
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
          )),
    );
  }

  Widget _FormElement({required String label, required Widget child}) {

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
