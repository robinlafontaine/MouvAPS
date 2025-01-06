import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mouvaps/pages/form/physical_activity_form_screen.dart';
import 'package:mouvaps/models/form_answers.dart';
import 'package:mouvaps/utils/button_styling.dart';
import 'package:mouvaps/utils/form_styling.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MedicalFormScreen extends StatefulWidget {
  final FormAnswers formAnswers;

  const MedicalFormScreen({super.key, required this.formAnswers});

  @override
  MedicalFormScreenState createState() => MedicalFormScreenState();
}

class MedicalFormScreenState extends State<MedicalFormScreen> {
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
          }
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
                          Text("Informations médicales",
                              style: ShadTheme.of(context).textTheme.h3),
                          const SizedBox(height: 16),
                          ShadInputFormField(
                            id: 'medical_history',
                            label: const Text(
                                "Quels sont vos antécédents médicaux ?",
                                style: labelTextStyle),
                            placeholder: const Text(
                                "Exemple : entorse de la cheville droite, etc.",
                                style: placeholderTextStyle),
                            keyboardType: TextInputType.text,
                            decoration: formInputDecoration,
                            validator: (v) {
                              if (v.isEmpty) {
                                return "Merci de renseigner vos antécédents médicaux";
                              }
                              widget.formAnswers.medicalHistory = v;
                              return null;

                            },
                          ),
                          const SizedBox(height: 16),
                          ShadInputFormField(
                            id: 'risk_factors',
                            label: const Text(
                                "Présentez-vous des facteurs de risques ?",
                                style: labelTextStyle),
                            placeholder: const Text(
                                "Exemple : tabagisme, hypertension, etc.",
                                style: placeholderTextStyle),
                            keyboardType: TextInputType.text,
                            decoration: formInputDecoration,
                            validator: (v) {
                              if (v.isEmpty) {
                                return "Merci d'indiquer si vous présentez des facteurs de risques";
                              }
                              widget.formAnswers.riskFactors = v;
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          ShadRadioGroupFormField<bool>(
                            id: 'medication_yes_no',
                            label: const Text(
                                "Avez-vous un traitement médicamenteux ?",
                                style: labelTextStyle),
                            items: const [
                              ShadRadio(value: true, label: Text('Oui')),
                              ShadRadio(value: false, label: Text('Non')),
                            ],
                            onChanged: (value) {
                              setState(() {});
                            },
                            validator: (v) {
                              if (v == null) {
                                return "Merci de répondre à la question";
                              }
                              if(v == false){
                                widget.formAnswers.medication = "Non";
                              }
                              return null;
                            },
                          ),
                          if (formKey.currentState?.value['medication_yes_no'] == true)
                          const SizedBox(height: 16),
                          if (formKey.currentState?.value['medication_yes_no'] == true)
                          ShadInputFormField(
                              id: 'medication',
                              label: const Text("Si oui lequel/lesquels  ?",
                                  style: labelTextStyle),
                              placeholder: const Text(
                                  "Exemple : Bétabloquant, vasodilatateurs, etc.",
                                  style: placeholderTextStyle),
                              keyboardType: TextInputType.text,
                              decoration: formInputDecoration,
                              validator: (v) {
                                if (v.isEmpty) {
                                  return "Merci de répondre à la question";
                                }
                                widget.formAnswers.medication = v;
                                return null;
                              }),
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
                                          PhysicalActivityFormScreen(formAnswers: widget.formAnswers,),
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
                        ]
                    )
                )
            )
        )
    );
  }
}
