import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mouvaps/models/FormAnswers.dart';
import 'package:mouvaps/utils/button_styling.dart';
import 'package:mouvaps/utils/form_styling.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:mouvaps/utils/constants.dart' as Constants;

class DietFormScreen extends StatefulWidget {
  final FormAnswers formAnswers;

  const DietFormScreen({super.key, required this.formAnswers});

  @override
  _DietFormScreenState createState() => _DietFormScreenState();
}

class _DietFormScreenState extends State<DietFormScreen> {
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
                          Text('Alimentation',
                              style: ShadTheme.of(context).textTheme.h3),
                          const SizedBox(height: 16),
                          ShadInputFormField(
                            id:'dietary_restrictions',
                            label: const Text(
                                'Avez-vous un régime particulier?',
                                style: LabelTextStyle),
                            placeholder: const Text("Exemple : végétarien, sans gluten, etc.",
                                style: PlaceholderTextStyle),
                            keyboardType: TextInputType.text,
                            decoration: FormInputDecoration,
                            validator: (v) {
                              if (v.isNotEmpty) {
                                widget.formAnswers.dietary_restrictions = v;
                                return null;
                              }
                              return "Merci de répondre à la question";
                            },
                          ),
                          //TODO: systeme avec mots clés pour les allergies
                          ShadInputFormField(
                            id: 'allergies',
                            label: const Text(
                                'Avez-vous des allergies alimentaires?',
                                style: LabelTextStyle),
                            placeholder: const Text("Exemple : arachides, crustacés, etc.",
                                style: PlaceholderTextStyle),
                            keyboardType: TextInputType.text,
                            decoration: FormInputDecoration,
                            validator: (v) {
                              if (v.isNotEmpty) {
                                widget.formAnswers.allergies = v;
                                return null;
                              }
                              return "Merci de répondre à la question";
                            },
                          ),
                          const SizedBox(height: 16),
                          ShadInputFormField(
                            id: 'food_hated',
                            label: const Text(
                                'Y-a-t-il des aliments que vous détestez ?',
                                style: LabelTextStyle),
                            placeholder: const Text("Aliments détestés",
                                style: PlaceholderTextStyle),
                            keyboardType: TextInputType.text,
                            decoration: FormInputDecoration,
                            validator: (v) {
                              if (v.isNotEmpty) {
                                widget.formAnswers.food_hated = v;
                                return null;
                              }
                              return "Merci de répondre à la question";
                            },
                          ),
                          const SizedBox(height: 16),
                          ShadInputFormField(
                            id:'expectations_needs_diet',
                            label: const Text(
                                'Quelles sont vos attentes et vos besoins pour le programme alimentaire?',
                                style: LabelTextStyle),
                            placeholder: const Text("Attentes et besoins",
                                style: PlaceholderTextStyle),
                            keyboardType: TextInputType.text,
                            decoration: FormInputDecoration,
                            validator: (v) {
                              if (v.isNotEmpty) {
                                widget.formAnswers.expectations_needs_diet = v;
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
                              //   TODO: envoyer les données
                              } else {}
                            },
                            child: const Text("Envoyer",
                                style: PrimaryButtonTextStyle),
                          )
                        ]
                    )
                ))));
  }
}

class AllergyBubbleWidget extends StatelessWidget {
  final String allergy;
  final Function removeIconFunction;

  const AllergyBubbleWidget({super.key, required this.allergy, required this.removeIconFunction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Constants.primaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(allergy, style: const TextStyle(color: Colors.white)),
          IconButton(
              onPressed: (){
                removeIconFunction();
              },
              icon: const Icon(Icons.close, color: Colors.white))

        ],
      ),
    );
  }
}
