import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mouvaps/models/form_answers.dart';
import 'package:mouvaps/services/pathology.dart';
import 'package:mouvaps/utils/button_styling.dart';
import 'package:mouvaps/utils/form_styling.dart';
import 'package:mouvaps/utils/text_utils.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:mouvaps/utils/constants.dart' as constants;

class DietFormScreen extends StatefulWidget {
  final FormAnswers formAnswers;

  const DietFormScreen({super.key, required this.formAnswers});

  @override
  DietFormScreenState createState() => DietFormScreenState();
}

class DietFormScreenState extends State<DietFormScreen> {
  final formKey = GlobalKey<ShadFormState>();
  final Future<List<Pathology>> pathologies = Pathology.getAll();
  var logger = Logger(printer: SimplePrinter());

  Future<void> _handleFormSubmission() async {
    if (formKey.currentState!.saveAndValidate()) {
      logger.d('Validation succeeded with ${formKey.currentState!.value}');
      try {
        final bool success = await widget.formAnswers.insert();

        if (success) {
          logger.d('Form answers inserted successfully');
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Échec de l\'enregistrement des réponses. Veuillez réessayer.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        logger.e('Failed to insert form answers: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Une erreur est survenue: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      logger.e('Validation failed with ${formKey.currentState!.value}');
    }
  }

  @override
  Widget build(BuildContext context) {
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
                                style: labelTextStyle),
                            placeholder: const Text("Exemple : végétarien, sans gluten, etc.",
                                style: placeholderTextStyle),
                            keyboardType: TextInputType.text,
                            decoration: formInputDecoration,
                            validator: (v) {
                              if (v.isNotEmpty) {
                                widget.formAnswers.dietaryRestrictions = v;
                                return null;
                              }
                              return "Merci de répondre à la question";
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text(
                              'Avez-vous des pathologies?',
                              style: labelTextStyle),
                          _buildPathologySelect(),
                          const SizedBox(height: 16),
                          ShadInputFormField(
                            id: 'allergies',
                            label: const Text(
                                'Avez-vous des allergies alimentaires?',
                                style: labelTextStyle),
                            placeholder: const Text("Exemple : arachides, crustacés, etc.",
                                style: placeholderTextStyle),
                            keyboardType: TextInputType.text,
                            decoration: formInputDecoration,
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
                                style: labelTextStyle),
                            placeholder: const Text("Aliments détestés",
                                style: placeholderTextStyle),
                            keyboardType: TextInputType.text,
                            decoration: formInputDecoration,
                            validator: (v) {
                              if (v.isNotEmpty) {
                                widget.formAnswers.foodHated = v;
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
                                style: labelTextStyle),
                            placeholder: const Text("Attentes et besoins",
                                style: placeholderTextStyle),
                            keyboardType: TextInputType.text,
                            decoration: formInputDecoration,
                            validator: (v) {
                              if (v.isNotEmpty) {
                                widget.formAnswers.expectationsNeedsDiet = v;
                                return null;
                              }
                              return "Merci de répondre à la question";
                            },
                          ),
                          const SizedBox(height: 16),
                          ShadButton(
                            onPressed: _handleFormSubmission,
                            child: const Text("Envoyer",
                                style: primaryButtonTextStyle),
                          )
                        ]
                    )
                )
            )
        )
    );
  }

  Widget _buildPathologySelect() {
    return FutureBuilder<List<Pathology>>(
      future: pathologies,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ShadSelect.multiple(
            minWidth: 340,
            onChanged: print,
            allowDeselection: true,
            closeOnSelect: false,
            placeholder: const Text('Sélectionnez vos pathologies'),
            initialValues: [snapshot.data!.first],
            options: snapshot.data!.map((e) => ShadOption(
              value: e,
              child: Text(e.name.capitalize()),
            )).toList(),
            selectedOptionsBuilder: (context, values) {
              widget.formAnswers.pathologies = values.cast<Pathology>();
              return Text(values.map((e) => e.name).join(', '));
            },
          );
        }
        return const CircularProgressIndicator();
      },
    );
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
        color: constants.primaryColor,
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
