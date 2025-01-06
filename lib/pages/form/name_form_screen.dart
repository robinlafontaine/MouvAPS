import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mouvaps/pages/form/identity_form_screen.dart';
import 'package:mouvaps/models/form_answers.dart';
import 'package:mouvaps/utils/button_styling.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:mouvaps/utils/constants.dart' as constants;

class NameFormScreen extends StatefulWidget {

  const NameFormScreen({super.key});

  @override
  NameFormScreenState createState() => NameFormScreenState();
}

class NameFormScreenState extends State<NameFormScreen>{

  final formKey = GlobalKey<ShadFormState>();

  @override
  Widget build(BuildContext context) {
    var logger = Logger(printer: SimplePrinter());
    return Scaffold(
      body: Center(
          child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350),child:
      ShadForm(
        key: formKey,
          child:
          Center(child:
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Bienvenue sur Mouv'Aps !", style: ShadTheme.of(context).textTheme.h1),
              const SizedBox(height: 16),
              ShadInputFormField(
                id: 'prenom',
                // label: const Text('Prénom', style:TextStyle(
                //   fontSize: Constants.form_label_font_size,
                //   fontWeight: Constants.form_label_font_weight,
                //   color: Constants.text_color,
                // ),),
                placeholder: const Text('Votre prénom', style:
                TextStyle(
                  color: constants.textFieldPlaceholderColor
                ),),
                keyboardType: TextInputType.text,
                decoration: const ShadDecoration(
                    color: constants.textFieldColor,
                ),
                validator: (v) {
                  if (v.isEmpty) {
                    return "Merci d'entrer votre prénom";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ShadInputFormField(
                id: 'nom',
                // label: const Text('Nom', style: TextStyle(
                //   fontSize: Constants.form_label_font_size,
                //   fontWeight: Constants.form_label_font_weight,
                //   color: Constants.text_color,
                // ),),
                placeholder: const Text('Votre Nom', style:
                TextStyle(
                  color: constants.textFieldPlaceholderColor,
                ),),
                keyboardType: TextInputType.text,
                decoration: const ShadDecoration(
                    color: constants.textFieldColor,
                ),
                validator: (v) {
                  if (v.isEmpty) {
                    return "Merci d'entrer votre nom";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ShadButton(
                onPressed: () {
                  if(formKey.currentState!.saveAndValidate()) {
                    logger.d("validation succeeded with ${formKey.currentState!.value}");
                    Navigator.push(context, 
                        PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => IdentityFormScreen(
                              formAnswers: FormAnswers(formKey.currentState!.value['prenom'], formKey.currentState!.value['nom']),),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              var begin = const Offset(1.0, 0.0);
                              var end = Offset.zero;
                              var curve = Curves.ease;
                              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);
                              return SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              );
                            }
                        ),

                    );
                  }
                  else {
                    logger.d("validation failed");
                  }
                },
                child: const Text('Suivant',style:primaryButtonTextStyle),
              )
            ],
          ))),))

    );
  }
}



