import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mouvaps/pages/form/diet_form_screen.dart';
import 'package:mouvaps/models/FormAnswers.dart';
import 'package:mouvaps/utils/button_styling.dart';
import 'package:mouvaps/utils/form_styling.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:mouvaps/utils/constants.dart' as Constants;

class PhysicalActivityFormScreen extends StatefulWidget {
  final FormAnswers formAnswers;

  const PhysicalActivityFormScreen({super.key, required this.formAnswers});

  @override
  _PhysicalActivityFormScreenState createState() =>
      _PhysicalActivityFormScreenState();
}

class _PhysicalActivityFormScreenState
    extends State<PhysicalActivityFormScreen> {
  final formKey = GlobalKey<ShadFormState>();

  @override
  Widget build(BuildContext context) {
    var logger = Logger(printer: SimplePrinter());
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
                child: ShadForm(
                    key: formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Activité physique',
                              style: ShadTheme.of(context).textTheme.h3),
                          const SizedBox(height: 16),
                          ShadRadioGroupFormField<bool>(
                            id:'physical_activity_yes_no',
                            label: const Text('Avez-vous fait de l’activité physique  ?',
                              style: LabelTextStyle,),
                              items: const [
                                ShadRadio(value: true, label: const Text('Oui')),
                                ShadRadio(value: false, label: const Text('Non')),
                              ],
                              onChanged: (value){
                              setState(() {

                              });
                              },
                              validator: (v) {
                                if (v == null) {
                                  return "Merci de renseigner si vous avez fait de l'activité physique";
                                }
                                if (v == false) {
                                  widget.formAnswers.physical_activity = "Non";
                                }
                                return null;
                              },
                          ),
                          if(formKey.currentState?.value['physical_activity_yes_no'] == true)
                          Column(
                            children: [
                              const SizedBox(height: 16),
                              ShadInputFormField(
                                id: 'physical_activity',
                                label: const Text(
                                    "Si oui laquelle/lesquelles?",
                                    style: LabelTextStyle),
                                placeholder: const Text("Activité physique", style: PlaceholderTextStyle),
                                keyboardType: TextInputType.text,
                                decoration: FormInputDecoration,
                                validator: (v) {
                                  if (v.isEmpty) {
                                    return "Merci de renseigner votre activité physique";
                                  }
                                  widget.formAnswers.physical_activity = v;
                                  return null;
                                },
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          ShadRadioGroupFormField<bool>(
                            id:'current_activity_yes_no',
                            label: const Text('Faites-vous de l’activité physique actuellement ?',
                            style: LabelTextStyle,),
                            items: const [
                              ShadRadio(value: true, label: const Text('Oui')),
                              ShadRadio(value: false, label: const Text('Non')),
                            ],
                            onChanged: (value){
                              setState(() {

                              });
                            },
                            validator: (v) {
                              if (v == null) {
                                return "Merci de répondre à la question";
                              }
                              if (v == false) {
                                widget.formAnswers.physical_activity = "Non";
                              }
                              return null;
                            },
                          ),
                          if(formKey.currentState?.value['current_activity_yes_no'] == true)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                ShadInputFormField(
                                  id: 'current_activity',
                                  label: const Text(
                                      "Si oui laquelle/lesquelles?",
                                      style: LabelTextStyle),
                                  placeholder: const Text("Activité physique", style: PlaceholderTextStyle),
                                  keyboardType: TextInputType.text,
                                  decoration: FormInputDecoration,
                                  validator: (v) {
                                    if (v.isEmpty) {
                                      return "Merci de renseigner votre activité physique";
                                    }
                                    widget.formAnswers.current_activity = v;
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                ShadInputFormField(
                                  id: 'current_activity_frequency',
                                  label: const Text(
                                      "A quelle fréquence ?",
                                      style: LabelTextStyle),
                                  placeholder: const Text("Fréquence", style: PlaceholderTextStyle),
                                  keyboardType: TextInputType.text,
                                  decoration: FormInputDecoration,
                                  validator: (v) {
                                    if (v.isEmpty) {
                                      return "Merci de renseigner votre activité physique";
                                    }
                                    widget.formAnswers.current_activity_time = v;
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                const Text("A quelle intensité ?",style: TextStyle(
                                  fontSize: 18 ,
                                  fontWeight: Constants.form_label_font_weight,
                                  color: Constants.textColor,
                                ),),
                                const SizedBox(height: 8),
                                ShadRadioGroupFormField<String>(
                                  id: 'current_activity_intensity',
                                  items: const [
                                    ShadRadio(value: 'Faible', label: Text('Faible')),
                                    ShadRadio(value: 'Moyenne', label: Text('Moyenne')),
                                    ShadRadio(value: 'Elevée', label: Text('Elevée')),
                                  ],
                                  onChanged: (value){
                                    setState(() {

                                    });
                                  },
                                  validator: (v) {
                                    if (v == null) {
                                      return "Merci de répondre à la question";
                                    }
                                    widget.formAnswers.current_activity_intensity = v;
                                    return null;
                                  },
                                ),]
                            ),
                          const SizedBox(height: 16),
                          ShadInputFormField(
                            id: 'activity_difficulties',
                            label: const Text("Avez-vous des difficultés pour faire de l’activité physique ",
                              style: LabelTextStyle,),
                            placeholder: const Text("Difficultés", style: PlaceholderTextStyle),
                            keyboardType: TextInputType.text,
                            decoration: FormInputDecoration,
                            validator: (v) {
                              if (v.isNotEmpty) {
                                widget.formAnswers.activity_difficulties = v;
                                return null;
                              }
                              return "Merci de répondre à la question";
                            },
                          ),
                          const SizedBox(height: 16),
                          ShadRadioGroupFormField<bool>(
                            id:'up_down_able',
                            label: const Text('Savez-vous vous mettre au sol et vous relever ?',
                              style: LabelTextStyle,),
                            items: const [
                              ShadRadio(value: true, label: const Text('Oui')),
                              ShadRadio(value: false, label: const Text('Non')),
                            ],
                            onChanged: (value){
                              setState(() {

                              });
                            },
                            validator: (v) {
                              if (v == null) {
                                return "Merci de répondre à la question";
                              }
                              widget.formAnswers.up_down_able = v;
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          ShadInputFormField(
                            id:'home_material',
                            label: const Text("Avez-vous du matériel sportif chez-vous ?",
                              style: LabelTextStyle,),
                            placeholder: const Text("Matériel sportif", style: PlaceholderTextStyle),
                            keyboardType: TextInputType.text,
                            decoration: FormInputDecoration,
                            validator: (v) {
                              if (v.isNotEmpty) {
                                widget.formAnswers.home_material = v;
                                return null;
                              }
                              return "Merci de répondre à la question";
                            },
                          ),
                          const SizedBox(height: 16),
                          ShadInputFormField(
                            id:'expectation_needs',
                            label: const Text("Quelles sont vos attentes et vos besoins pour le programme sportif ?",
                              style: LabelTextStyle,),
                            placeholder: const Text("Attentes et besoins", style: PlaceholderTextStyle),
                            keyboardType: TextInputType.text,
                            decoration: FormInputDecoration,
                            validator: (v) {
                              if (v.isNotEmpty) {
                                widget.formAnswers.expectations_needs_sport = v;
                                return null;
                              }
                              return "Merci de répondre à la question";
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
                                          DietFormScreen(formAnswers: widget.formAnswers,),
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
                        ])))));
  }
}
