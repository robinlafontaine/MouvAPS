import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:mouvaps/pages/form/medical_form_screen.dart';
import 'package:mouvaps/services/form_answers.dart';
import 'package:mouvaps/services/pathology.dart';
import 'package:mouvaps/utils/button_styling.dart';
import 'package:mouvaps/utils/form_styling.dart';
import 'package:mouvaps/utils/text_utils.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:mouvaps/utils/constants.dart' as constants;

class IdentityFormScreen extends StatefulWidget {
  final FormAnswers formAnswers;

  const IdentityFormScreen(
      {super.key,required this.formAnswers});

  @override
  IdentityFormScreenState createState() => IdentityFormScreenState();
}

class IdentityFormScreenState extends State<IdentityFormScreen> {
  final formKey = GlobalKey<ShadFormState>();
  final Future<List<Pathology>> pathologies = Pathology.getAll();

  @override
  Widget build(BuildContext context) {
    var logger = Logger(printer: SimplePrinter());

    return Scaffold(
        body: Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: ShadForm(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(TextSpan(
                        text: 'Bonjour',
                        style: ShadTheme.of(context).textTheme.h1,
                        children: [
                          TextSpan(
                            text: ' ${widget.formAnswers.name}',
                            style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: constants.textColor),
                          ),
                          TextSpan(
                            text: ', bienvenue sur Mouv\'Aps !',
                            style: ShadTheme.of(context).textTheme.h1,
                          )
                        ])),
                    const SizedBox(height: 16),
                    Text(
                      'Commençons par quelques questions pour mieux vous connaître.',
                      style: ShadTheme.of(context).textTheme.p,
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 16),
                    Text("Votre identité",
                        style: ShadTheme.of(context).textTheme.h3),
                    const SizedBox(height: 16),
                    ShadDatePickerFormField(
                      id: 'birthday',
                      label: const Text('Quelle est votre date de naissance ?',
                          style: labelTextStyle),
                      placeholder: const Text('Date de naissance'),
                      validator: (v) {
                        if (v == null) {
                          return "Merci d'entrer votre date de naissance";
                        }
                        widget.formAnswers.birthday = v;
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    //input deroulant pour le sexe
                    const Text('Quel est votre sexe?', style: labelTextStyle),
                    ShadSelectFormField<String>(
                      id: 'sexe',
                      placeholder: const Text(
                        'Sexe',
                        style: placeholderTextStyle,
                      ),
                      options: [
                        ...constants.genresOptions.entries.map((e) =>
                            ShadOption(value: e.key, child: Text(e.value)))
                      ],
                      initialValue: widget.formAnswers.gender.isEmpty?null:widget.formAnswers.gender,
                      selectedOptionBuilder: (context, value) =>
                          Text(constants.genresOptions[value]!),
                      validator: (v) {
                        if (v == null) {
                          return "Veuillez choisir une option";
                        } else {
                          widget.formAnswers.gender = v;
                          return null;
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    ShadInputFormField(
                      id: 'taille',
                      label: Text.rich(
                        TextSpan(
                            text: 'Quelle est votre taille? ',
                            style: labelTextStyle,
                            children: [
                              TextSpan(
                                  text: '(en cm)',
                                  style: ShadTheme.of(context).textTheme.small)
                            ]),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      initialValue: "${widget.formAnswers.height==-1?'':widget.formAnswers.height}",
                      placeholder: const Text('Votre taille',
                          style: placeholderTextStyle),
                      decoration: formInputDecoration,
                      validator: (v) {
                        if (v.isEmpty) {
                          return "Merci d'entrer votre taille";
                        }
                        widget.formAnswers.height = int.parse(v);
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ShadInputFormField(
                      id: 'poids',
                      label: Text.rich(
                        TextSpan(
                            text: 'Quel est votre poids? ',
                            style: labelTextStyle,
                            children: [
                              TextSpan(
                                  text: '(en kg)',
                                  style: ShadTheme.of(context).textTheme.small)
                            ]),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[\d\.]|[\d\,]'))
                      ],
                      initialValue: "${widget.formAnswers.weight==-1?'':widget.formAnswers.weight}",
                      placeholder: const Text('Votre poids',
                          style: placeholderTextStyle),
                      decoration: formInputDecoration,
                      validator: (v) {
                        if (v.isEmpty) {
                          return "Merci d'entrer votre poids";
                        }
                        widget.formAnswers.weight = double.parse(v);
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                        'Avez-vous des pathologies?',
                        style: labelTextStyle),
                    const SizedBox(height: 8),
                    _buildPathologySelect(),
                    const SizedBox(height: 16),
                    ShadRadioGroupFormField<bool>(
                      id: 'pregnant',
                      label: const Text('Êtes-vous enceinte?',
                          style: labelTextStyle),
                      items: const [
                        ShadRadio(value: true, label: Text('Oui')),
                        ShadRadio(value: false, label: Text('Non')),
                      ],
                      validator: (v) {
                        if (v == null) {
                          return "Veuillez choisir une option";
                        }
                        widget.formAnswers.pregnant = v;
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ShadSelectFormField<String>(
                      id: 'job_physicality',
                      label: const Text('Votre métier est-il :',
                          style: labelTextStyle),
                      placeholder: const Text('Métier', style: placeholderTextStyle),
                      options: [
                        ...constants.jobPhysicalityOptions.entries.map((e) =>
                            ShadOption(value: e.key, child: Text(e.value)))
                      ],
                      // initialValue: widget.formAnswers.job.isEmpty?null:widget.formAnswers.job,
                      selectedOptionBuilder: (context, value) =>
                          Text(constants.jobPhysicalityOptions[value]!),
                      validator: (v) {
                        if (v == null) {
                          return "Veuillez choisir une option";
                        } else {
                          widget.formAnswers.jobPhysicality = v;
                          return null;
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    ShadButton(
                      onPressed: () {
                        if (formKey.currentState!.saveAndValidate()) {
                          logger.d(
                              'Validation succeeded with ${formKey.currentState!.value}');
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        MedicalFormScreen(formAnswers: widget.formAnswers,),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  var begin = const Offset(1.0, 0.0);
                                  var end = Offset.zero;
                                  var curve = Curves.ease;
                                  var tween = Tween(begin: begin, end: end)
                                      .chain(CurveTween(curve: curve));
                                  var offsetAnimation = animation.drive(tween);
                                  return SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  );
                                }),
                          );
                        } else {}
                      },
                      child: const Text("Continuer",
                          style: primaryButtonTextStyle),
                    )
                  ],
                ),
              ),
            )));
  }

  Widget _buildPathologySelect() {
    return FutureBuilder<List<Pathology>>(
      future: pathologies,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: [
              ShadSelect<Pathology>.multiple(
                minWidth: 340,
                onChanged: print,
                allowDeselection: true,
                closeOnSelect: false,
                placeholder: const Text('Sélectionnez vos pathologies',style: placeholderTextStyle,),
                options: snapshot.data!.map((e) => ShadOption(
                  value: e,
                  child: Text(e.name.capitalize()),
                )).toList(),
                selectedOptionsBuilder: (context, values) {
                  widget.formAnswers.pathologies = values.cast<Pathology>();
                  return Text(values.map((e) => e.name.capitalize()).join(', '));
                },
              ),

            ],
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}






