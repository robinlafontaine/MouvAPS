import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mouvaps/pages/form/physical_activity_form_screen.dart';
import 'package:mouvaps/services/form_answers.dart';
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
                          ShadRadioGroupFormField<bool>(
                            id: 'medication',
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
                              widget.formAnswers.medication = v;
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
