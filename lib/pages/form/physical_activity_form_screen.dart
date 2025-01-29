import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mouvaps/pages/form/diet_form_screen.dart';
import 'package:mouvaps/services/form_answers.dart';
import 'package:mouvaps/services/home_material.dart';
import 'package:mouvaps/services/sport_expectations.dart';
import 'package:mouvaps/utils/button_styling.dart';
import 'package:mouvaps/utils/form_styling.dart';
import 'package:mouvaps/utils/text_utils.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:mouvaps/utils/constants.dart' as constants;

class PhysicalActivityFormScreen extends StatefulWidget {
  final FormAnswers formAnswers;

  const PhysicalActivityFormScreen({super.key, required this.formAnswers});

  @override
  PhysicalActivityFormScreenState createState() =>
      PhysicalActivityFormScreenState();
}

class PhysicalActivityFormScreenState extends State<PhysicalActivityFormScreen> {
  final formKey = GlobalKey<ShadFormState>();
  final Future<List<HomeMaterial>> homeMaterials = HomeMaterial.getAll();
  final Future<List<SportExpectations>> sportExpectations = SportExpectations.getAll();

  bool sportExpectationsError = false;
  bool homematerialError = false;
  var logger = Logger(printer: SimplePrinter());


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
              widget.formAnswers.sportExpectations = [];
              widget.formAnswers.homeMaterial = [];
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
                          const  SizedBox(height: 16),
                          ShadRadioGroupFormField<bool>(
                              id: 'physical_activity_regular',
                              label: const Text(
                                  'Pratiquez-vous une activité physique régulière ?',
                                  style: labelTextStyle),
                              items: const [
                                ShadRadio(value: true, label: Text('Oui')),
                                ShadRadio(value: false, label: Text('Non')),
                              ],
                              onChanged: (value) {
                                setState(() {

                                });
                              },
                              validator: (v) {
                                if (v == null) {
                                  return "Merci de répondre à la question";
                                }
                                widget.formAnswers.physicalActivityRegular = v;
                                return null;
                              }),
                          const SizedBox(height: 16),
                          if(formKey.currentState?.value['physical_activity_regular'] == true)
                            Column(
                              children: [
                                const SizedBox(height: 16),
                                ShadSelectFormField<String>(
                                  id: 'activity_level',
                                  label: const Text("Quel est votre niveau dans l'activité ?",
                                      style: labelTextStyle),
                                  placeholder: const Text('Niveau', style: placeholderTextStyle),
                                  options: [
                                    ...constants.activityLevelOptions.entries.map((e) =>
                                        ShadOption(value: e.key, child: Text(e.value)))
                                  ],
                                  // initialValue: widget.formAnswers.job.isEmpty?null:widget.formAnswers.job,
                                  selectedOptionBuilder: (context, value) =>
                                      Text(constants.activityLevelOptions[value]!),
                                  validator: (v) {
                                    if (v == null) {
                                      return "Veuillez choisir une option";
                                    } else {
                                      widget.formAnswers.physicalActivityLevel = v;
                                      return null;
                                    }
                                  },
                                )
                              ],
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
                          ShadRadioGroupFormField<bool>(
                              id:'home_material_yes_no',
                              label: const Text('Avez-vous du matériel sportif chez-vous ?',
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
                                return null;
                              }),

                          if(formKey.currentState?.value['home_material_yes_no'] == true)
                            Column(
                              children: [
                                const SizedBox(height: 16),
                                _buildHomeMaterialSelect(homematerialError),
                              ],
                            ),
                          const SizedBox(height: 16),
                          const Text("Quelles sont vos attentes et besoins pour le programme sportif ?", style: labelTextStyle),
                          const SizedBox(height: 8),
                          _buildSportExpectationsSelect(sportExpectationsError),
                          const SizedBox(height: 16),
                          ShadButton(
                            onPressed: () {
                              _handleFormSubmission();
                            },
                            child: const Text("Continuer",
                                style: primaryButtonTextStyle),
                          )
                        ])))));
  }

  void _handleFormSubmission() {
    if(widget.formAnswers.sportExpectations.isEmpty){
      setState(() {
        sportExpectationsError = true;
      });
    } else {
      setState(() {
        sportExpectationsError = false;
      });
    }
    if(formKey.currentState?.value['home_material_yes_no'] && widget.formAnswers.homeMaterial.isEmpty){
      setState(() {
        homematerialError = true;
      });
    } else {
      setState(() {
        homematerialError = false;
      });
    }
    if (formKey.currentState!.saveAndValidate()) {
      logger.d('Validation succeeded with ${formKey.currentState!.value}');
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

    } else {
      logger.e('Validation failed with ${formKey.currentState!.value}');
    }
  }

  Widget _buildHomeMaterialSelect(bool homeMaterialError) {
    return FutureBuilder<List<HomeMaterial>>(
      future: homeMaterials,
      builder: (context, snapshot) {
        if(snapshot.hasError){
          return const Text('Erreur de chargement des matériels sportifs');
        }
        if (snapshot.hasData) {
          return Column(
            children: [
              ShadSelect<HomeMaterial>.multiple(
                allowDeselection: true,
                closeOnSelect: false,
                minWidth: 340,
                placeholder: const Text('Sélectionnez du matériel', style: placeholderTextStyle),
                options: snapshot.data!.map((e) => ShadOption(
                  value: e,
                  child: Text(e.name.capitalize()),
                )).toList(),
                selectedOptionsBuilder: (context, values) {
                  widget.formAnswers.homeMaterial = values;
                  return Text(values.map((e) => e.name.capitalize()).join(', '));
                },
              ),
              if(homeMaterialError)
                const Text('Merci de sélectionner au moins un matériel sportif', style: errorTextStyle)
            ],
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }

  Widget _buildSportExpectationsSelect(bool sportExpectationsError) {
    return FutureBuilder<List<SportExpectations>>(
      future: sportExpectations,
      builder: (context, snapshot) {
        if(snapshot.hasError){
          return const Text('Erreur de chargement des attentes sportives');
        }
        if (snapshot.hasData) {
          return Column(
            children: [
              ShadSelect<SportExpectations>.multiple(
                allowDeselection: true,
                closeOnSelect: false,
                minWidth: 340,
                placeholder: const Text('Sélectionnez une attente', style: placeholderTextStyle),
                options: snapshot.data!.map((e) => ShadOption(
                  value: e,
                  child: Text(e.name.capitalize()),
                )).toList(),
                selectedOptionsBuilder: (context, values) {
                  // add values to formAnswers
                  widget.formAnswers.sportExpectations = values;
                  return Text(values.map((e) => e.name.capitalize()).join(', '));
                },
              ),
              if(sportExpectationsError)
                const Text('Merci de sélectionner au moins une attente sportive', style: errorTextStyle)
            ],
          );
        }
        return const CircularProgressIndicator();
      },
    );

  }
}
