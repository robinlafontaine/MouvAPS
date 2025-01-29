import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:mouvaps/utils/constants.dart' as constants;

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  var logger = Logger(printer: SimplePrinter());
  final formKey = GlobalKey<ShadFormState>();

  bool _isValidEmailFormat(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 52),
          child: Center(
            child: ShadForm(
              key: formKey,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 350),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/icon.png',
                      height: 100,
                    ),
                    const SizedBox(height: 16),
                    Text('Se connecter',
                        textAlign: TextAlign.center,
                        style: ShadTheme.of(context).textTheme.h1),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 350,
                      child: ShadInputFormField(
                        id: 'email',
                        label: const Text('Adresse mail', style: TextStyle(
                          fontSize: constants.h3FontSize,
                          fontWeight: FontWeight.w500,
                          color: constants.textColor,
                        ),),
                        placeholder: const Text('mail@example.com', style: TextStyle(
                          color : constants.textFieldPlaceholderColor,
                        ),),
                        keyboardType: TextInputType.emailAddress,
                        prefix: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(LucideIcons.mail, size: 16),
                        ),
                        decoration: const ShadDecoration(
                            color: constants.textFieldColor,
                        ),
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Entrez votre adresse mail';
                          } else if (!_isValidEmailFormat(value)) {
                            return 'Entrez une adresse mail valide';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    ShadButton(
                      width: 350,
                      height: 48,
                      onPressed: () {
                        if (formKey.currentState!.saveAndValidate()) {
                          logger.d('Validation succeeded with ${formKey.currentState!.value}');
                          Navigator.pushNamed(context, '/otp', arguments: formKey.currentState!.value['email']);
                          logger.d('Signing in with email: ${formKey.currentState!.value['email']}');
                        } else {
                          logger.d('Validation failed');
                        }
                      },
                      child: const Text("Recevoir un code", style: TextStyle(
                        color: constants.buttonTextColor,
                        fontSize: constants.buttonTextFontSize,
                        fontVariations:[
                          FontVariation(
                              'wght', constants.buttonTextFontWeight
                          )
                        ],
                      )),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}