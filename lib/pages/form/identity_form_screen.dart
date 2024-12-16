import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:mouvaps/pages/form/medical_form_screen.dart';
import 'package:mouvaps/models/FormAnswers.dart';
import 'package:mouvaps/utils/button_styling.dart';
import 'package:mouvaps/utils/form_styling.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:mouvaps/utils/constants.dart' as Constants;

class IdentityFormScreen extends StatefulWidget {
  final FormAnswers formAnswers;

  IdentityFormScreen(
      {super.key,required this.formAnswers});

  @override
  _IdentityFormScreenState createState() => _IdentityFormScreenState();
}

class _IdentityFormScreenState extends State<IdentityFormScreen> {
  final formKey = GlobalKey<ShadFormState>();

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
                                color: Constants.textColor),
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
                    ShadInputFormField(
                      id: 'age',
                      label: const Text('Quel est votre âge?',
                          style: LabelTextStyle),
                      placeholder:
                          const Text('Votre âge', style: PlaceholderTextStyle),

                      initialValue: "${widget.formAnswers.age==-1?'':widget.formAnswers.age}",
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: FormInputDecoration,
                      validator: (v) {
                        if (v.isEmpty) {
                          return "Merci d'entrer votre âge";
                        }
                        widget.formAnswers.age = int.parse(v);
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    //input deroulant pour le sexe
                    const Text('Quel est votre sexe?', style: LabelTextStyle),
                    ShadSelectFormField<String>(
                      id: 'sexe',
                      placeholder: const Text(
                        'Sexe',
                        style: PlaceholderTextStyle,
                      ),
                      options: [
                        ...Constants.genres.entries.map((e) =>
                            ShadOption(value: e.key, child: Text(e.value)))
                      ],
                      initialValue: widget.formAnswers.sex.isEmpty?null:widget.formAnswers.sex,
                      selectedOptionBuilder: (context, value) =>
                          Text(Constants.genres[value]!),
                      validator: (v) {
                        if (v == null) {
                          return "Veuillez choisir une option";
                        } else {
                          widget.formAnswers.sex = v;
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
                            style: LabelTextStyle,
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
                          style: PlaceholderTextStyle),
                      decoration: FormInputDecoration,
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
                            style: LabelTextStyle,
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
                          style: PlaceholderTextStyle),
                      decoration: FormInputDecoration,
                      validator: (v) {
                        if (v.isEmpty) {
                          return "Merci d'entrer votre poids";
                        }
                        widget.formAnswers.weight = double.parse(v);
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ShadInputFormField(
                      id: 'handicap',
                      label: const Text(
                        'Souffrez-vous d\'une maladie ou d\'un handicap?',
                        style: LabelTextStyle,
                      ),
                      placeholder: const Text(
                          'Ex: maladie cardiaque : syndrome coronarien aigu',
                          style: PlaceholderTextStyle),
                      decoration: FormInputDecoration,
                      validator: (v) {
                        if (v.isNotEmpty) {
                          widget.formAnswers.handicap = v;
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    ShadSelectFormField<String>(
                      id: 'family_situation',
                      label: const Text('Quelle est votre situation familiale?',
                          style: LabelTextStyle),
                      placeholder:
                          const Text('Situation', style: PlaceholderTextStyle),
                      options: [
                        ...Constants.family_situations.entries.map((e) =>
                            ShadOption(value: e.key, child: Text(e.value)))
                      ],
                      selectedOptionBuilder: (context, value) =>
                          Text(Constants.family_situations[value]!),
                      validator: (v) {
                        if (v == null) {
                          return "Veuillez choisir une option";
                        }
                        widget.formAnswers.family_situation = v;
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ShadRadioGroupFormField<bool>(
                      id: 'retired',
                      label: const Text('Êtes-vous retraité(e)?',
                          style: LabelTextStyle),
                      items: const [
                        ShadRadio(value: true, label: Text('Oui')),
                        ShadRadio(value: false, label: Text('Non')),
                      ],
                      validator: (v) {
                        if (v == null) {
                          return "Veuillez choisir une option";
                        }
                        widget.formAnswers.retired = v;
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ShadInputFormField(
                      id: 'children',
                      label: const Text('Combien avez-vous d\'enfants?',
                          style: LabelTextStyle),
                      placeholder: const Text('Nombre d\'enfants',
                          style: PlaceholderTextStyle),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: FormInputDecoration,
                      validator: (v) {
                        if (v.isEmpty) {
                          return "Merci d'entrer le nombre d'enfants";
                        }
                        widget.formAnswers.children = int.parse(v);
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ShadRadioGroupFormField<bool>(
                      id: 'pregnant',
                      label: const Text('Êtes-vous enceinte?',
                          style: LabelTextStyle),
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
                    ShadRadioGroupFormField<bool>(
                      id: 'home_floors',
                      label: const Text(
                          'Votre habitat comporte-t-il des étages?',
                          style: LabelTextStyle),
                      items: const [
                        ShadRadio(value: true, label: Text('Oui')),
                        ShadRadio(value: false, label: Text('Non')),
                      ],
                      onChanged: (value) {
                        setState(() {});
                      },
                      validator: (v) {
                        if (v == null) {
                          return "Veuillez choisir une option";
                        }
                        widget.formAnswers.home_floors = v;
                        return null;
                      },
                    ),
                    if (formKey.currentState?.value['home_floors'] == true)
                      ShadInputFormField(
                        id: 'home_floors_number',
                        label: const Text('Si oui combien?',
                            style: LabelTextStyle),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        placeholder: const Text('Nombre d\'étages',
                            style: PlaceholderTextStyle),
                        decoration: FormInputDecoration,
                        validator: (v) {
                          if (v.isEmpty &&
                              formKey.currentState?.value['home_floors'] ==
                                  true) {
                            return "Merci d'entrer le nombre d'étages";
                          }
                          widget.formAnswers.home_floors_number = int.parse(v);
                          return null;
                        },
                      ),
                    const SizedBox(height: 16),
                    ShadRadioGroupFormField<bool>(
                      id: 'home_stairs',
                      label: const Text(
                          'Accède-t-on à votre habitat par des escaliers?',
                          style: LabelTextStyle),
                      items: const [
                        ShadRadio(value: true, label: Text('Oui')),
                        ShadRadio(value: false, label: Text('Non')),
                      ],
                      validator: (v) {
                        if (v == null) {
                          return "Veuillez choisir une option";
                        }
                        widget.formAnswers.home_stairs = v;
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ShadInputFormField(
                      id: 'job',
                      label: const Text(
                          'Quel est votre profession ou que faites-vous actuellement?',
                          style: LabelTextStyle),
                      placeholder: const Text('Votre profession',
                          style: PlaceholderTextStyle),
                      decoration: FormInputDecoration,
                      validator: (v) {
                        if (v.isEmpty) {
                          return "Merci d'entrer votre profession";
                        }
                        widget.formAnswers.job = v;
                        return null;
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
                          style: PrimaryButtonTextStyle),
                    )
                  ],
                ),
              ),
            )));
  }
}
