import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mouvaps/pages/form/diet_form_screen.dart';
import 'package:mouvaps/models/form_answers.dart';
import 'package:mouvaps/utils/button_styling.dart';
import 'package:mouvaps/utils/form_styling.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:mouvaps/utils/constants.dart' as constants;

class PhysicalActivityFormScreen extends StatefulWidget {
  final FormAnswers formAnswers;

  const PhysicalActivityFormScreen({super.key, required this.formAnswers});

  @override
  PhysicalActivityFormScreenState createState() =>
      PhysicalActivityFormScreenState();
}

class PhysicalActivityFormScreenState
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
                              style: labelTextStyle,),
                              items: const [
                                ShadRadio(value: true, label: Text('Oui')),
                                ShadRadio(value: false, label: Text('Non')),
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
                                  widget.formAnswers.physicalActivity = "Non";
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
                                    style: labelTextStyle),
                                placeholder: const Text("Activité physique", style: placeholderTextStyle),
                                keyboardType: TextInputType.text,
                                decoration: formInputDecoration,
                                validator: (v) {
                                  if (v.isEmpty) {
                                    return "Merci de renseigner votre activité physique";
                                  }
                                  widget.formAnswers.physicalActivity = v;
                                  return null;
                                },
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          ShadRadioGroupFormField<bool>(
                            id:'current_activity_yes_no',
                            label: const Text('Faites-vous de l’activité physique actuellement ?',
                            style: labelTextStyle,),
                            items: const [
                              ShadRadio(value: true, label: Text('Oui')),
                              ShadRadio(value: false, label: Text('Non')),
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
                                widget.formAnswers.physicalActivity = "Non";
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
                                      style: labelTextStyle),
                                  placeholder: const Text("Activité physique", style: placeholderTextStyle),
                                  keyboardType: TextInputType.text,
                                  decoration: formInputDecoration,
                                  validator: (v) {
                                    if (v.isEmpty) {
                                      return "Merci de renseigner votre activité physique";
                                    }
                                    widget.formAnswers.currentActivity = v;
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                ShadInputFormField(
                                  id: 'current_activity_frequency',
                                  label: const Text(
                                      "A quelle fréquence ?",
                                      style: labelTextStyle),
                                  placeholder: const Text("Fréquence", style: placeholderTextStyle),
                                  keyboardType: TextInputType.text,
                                  decoration: formInputDecoration,
                                  validator: (v) {
                                    if (v.isEmpty) {
                                      return "Merci de renseigner votre activité physique";
                                    }
                                    widget.formAnswers.currentActivityTime = v;
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                const Text("A quelle intensité ?",style: TextStyle(
                                  fontSize: 18 ,
                                  fontWeight: constants.formLabelFontWeight,
                                  color: constants.textColor,
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
                                    widget.formAnswers.currentActivityIntensity = v;
                                    return null;
                                  },
                                ),]
                            ),
                          const SizedBox(height: 16),
                          ShadInputFormField(
                            id: 'activity_difficulties',
                            label: const Text("Avez-vous des difficultés pour faire de l’activité physique ",
                              style: labelTextStyle,),
                            placeholder: const Text("Difficultés", style: placeholderTextStyle),
                            keyboardType: TextInputType.text,
                            decoration: formInputDecoration,
                            validator: (v) {
                              if (v.isNotEmpty) {
                                widget.formAnswers.activityDifficulties = v;
                                return null;
                              }
                              return "Merci de répondre à la question";
                            },
                          ),
                          const SizedBox(height: 16),
                          ShadRadioGroupFormField<bool>(
                            id:'up_down_able',
                            label: const Text('Savez-vous vous mettre au sol et vous relever ?',
                              style: labelTextStyle,),
                            items: const [
                              ShadRadio(value: true, label: Text('Oui')),
                              ShadRadio(value: false, label: Text('Non')),
                            ],
                            onChanged: (value){
                              setState(() {

                              });
                            },
                            validator: (v) {
                              if (v == null) {
                                return "Merci de répondre à la question";
                              }
                              widget.formAnswers.upDownAble = v;
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          ShadInputFormField(
                            id:'home_material',
                            label: const Text("Avez-vous du matériel sportif chez-vous ?",
                              style: labelTextStyle,),
                            placeholder: const Text("Matériel sportif", style: placeholderTextStyle),
                            keyboardType: TextInputType.text,
                            decoration: formInputDecoration,
                            validator: (v) {
                              if (v.isNotEmpty) {
                                widget.formAnswers.homeMaterial = v;
                                return null;
                              }
                              return "Merci de répondre à la question";
                            },
                          ),
                          const SizedBox(height: 16),
                          ShadInputFormField(
                            id:'expectation_needs',
                            label: const Text("Quelles sont vos attentes et vos besoins pour le programme sportif ?",
                              style: labelTextStyle,),
                            placeholder: const Text("Attentes et besoins", style: placeholderTextStyle),
                            keyboardType: TextInputType.text,
                            decoration: formInputDecoration,
                            validator: (v) {
                              if (v.isNotEmpty) {
                                widget.formAnswers.expectationsNeedsSport = v;
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
                                style: primaryButtonTextStyle),
                          )
                        ])))));
  }
}
