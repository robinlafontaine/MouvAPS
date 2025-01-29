import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mouvaps/services/allergy.dart';
import 'package:mouvaps/services/diet.dart';
import 'package:mouvaps/services/diet_expectations.dart';
import 'package:mouvaps/services/form_answers.dart';
import 'package:mouvaps/utils/button_styling.dart';
import 'package:mouvaps/utils/form_styling.dart';
import 'package:mouvaps/utils/text_utils.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class DietFormScreen extends StatefulWidget {
  final FormAnswers formAnswers;

  const DietFormScreen({super.key, required this.formAnswers});

  @override
  DietFormScreenState createState() => DietFormScreenState();
}

class DietFormScreenState extends State<DietFormScreen> {
  final formKey = GlobalKey<ShadFormState>();
  final Future<List<Diet>> diets = Diet.getAll();
  final Future<List<Allergy>> allergies = Allergy.getAll();

  bool dieExpectationsEterror = false;

  var logger = Logger(printer: SimplePrinter());

  Future<void> _handleFormSubmission() async {
    if(widget.formAnswers.dietExpectations.isEmpty){
      setState(() {
        dieExpectationsEterror = true;
      });
    }
    else{
      setState(() {
        dieExpectationsEterror = false;
      });
    }
    if (formKey.currentState!.saveAndValidate()
    && !dieExpectationsEterror ) {
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
              // Reset form answers
              widget.formAnswers.dietaryRestrictions = [];
              widget.formAnswers.allergies = [];
              widget.formAnswers.dietExpectations = [];
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
                          const Text("Avez-vous un régime alimentaire particulier ?", style: labelTextStyle,),
                          const SizedBox(height: 8),
                          _buildDietSelect(),
                          const SizedBox(height: 16),
                          const Text("Avez-vous des allergies ?", style: labelTextStyle,),
                          const SizedBox(height: 8),
                          _buildAllergySelect(),
                          const SizedBox(height: 16),
                          const Text("Quelles sont vos attentes et besoin pour le programme alimentaire ?", style: labelTextStyle,),
                          const SizedBox(height: 8),
                          _buildDietExpectationsSelect(dieExpectationsEterror),
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

  Widget _buildAllergySelect(){
    return FutureBuilder<List<Allergy>>(
      future: allergies,
      builder: (context, snapshot) {
        if(snapshot.hasError){
          return const Text('Erreur de chargement des allergies');
        }
        if (snapshot.hasData) {
          return ShadSelect<Allergy>.multiple(
            allowDeselection: true,
            closeOnSelect: false,
            minWidth: 340,
            placeholder: const Text('Sélectionnez des allergies', style: placeholderTextStyle),
            options: snapshot.data!.map((e) => ShadOption(
              value: e,
              child: Text(e.name.capitalize()),
            )).toList(),
            selectedOptionsBuilder: (context, values) {
              widget.formAnswers.allergies = values;
              return Text(values.map((e) => e.name).join(', '));
            },
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }

  Widget _buildDietSelect(){
    return FutureBuilder<List<Diet>>(
      future: diets,
      builder: (context, snapshot) {
        if(snapshot.hasError){
          return const Text('Erreur de chargement des régimes alimentaires');
        }
        if (snapshot.hasData) {
          return
              ShadSelect<Diet>.multiple(
                allowDeselection: true,
                closeOnSelect: false,
                minWidth: 340,
                placeholder: const Text('Sélectionnez un régime', style: placeholderTextStyle),
                options: snapshot.data!.map((e) => ShadOption(
                  value: e,
                  child: Text(e.name.capitalize()),
                )).toList(),
                selectedOptionsBuilder: (context, values) {
                  widget.formAnswers.dietaryRestrictions = values;
                  return Text(values.map((e) => e.name.capitalize()).join(', '));
                },


          );
        }
        return const CircularProgressIndicator();
      },
    );
  }

  Widget _buildDietExpectationsSelect(bool dieExpectationsEterror) {
    return FutureBuilder<List<DietExpectations>>(
      future: DietExpectations.getAll(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Erreur de chargement des attentes alimentaires');
        }

        if (snapshot.hasData) {
          if(widget.formAnswers.dietExpectations.isEmpty){
          return Column(
            children: [
              ShadSelect<DietExpectations>.multiple(
                allowDeselection: true,
                closeOnSelect: false,
                minWidth: 340,
                placeholder: const Text('Sélectionnez des attentes alimentaires', style: placeholderTextStyle),
                options: snapshot.data!.map((e) => ShadOption(
                  value: e,
                  child: Text(e.name.capitalize()),
                )).toList(),
                selectedOptionsBuilder: (context, values) {
                  widget.formAnswers.dietExpectations = values;
                  return Text(values.map((e) => e.name.capitalize()).join(', '));
                },
              ),
              if(dieExpectationsEterror)
                const Text('Merci de sélectionner au moins une attente alimentaire', style: errorTextStyle)
            ],
          );
          }
          else{
            return Column(
              children: [
                ShadSelect<DietExpectations>.multiple(
                  allowDeselection: true,
                  closeOnSelect: false,
                  minWidth: 340,
                  placeholder: const Text('Sélectionnez des attentes alimentaires', style: placeholderTextStyle),
                  initialValues: widget.formAnswers.dietExpectations,
                  options: snapshot.data!.map((e) => ShadOption(
                    value: e,
                    child: Text(e.name.capitalize()),
                  )).toList(),
                  selectedOptionsBuilder: (context, values) {
                    widget.formAnswers.dietExpectations = values;
                    return Text(values.map((e) => e.name.capitalize()).join(', '));
                  },
                ),
                if(dieExpectationsEterror)
                  const Text('Merci de sélectionner au moins une attente alimentaire', style: errorTextStyle)
              ],
            );
          }
        }
        return const CircularProgressIndicator();
      },
    );
  }

}
