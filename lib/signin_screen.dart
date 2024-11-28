import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mouvaps/otp_screen.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
      appBar: AppBar(
        title: const Text('Connexion'),
      ),
      body: Center(
        child: ShadForm(
          key: formKey,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 350),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const ShadImage(
                  'https://avatars.githubusercontent.com/u/124599?v=4',
                  height: 100,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Se connecter',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 16),
                ShadInputFormField(
                  id: 'email',
                  label: const Text('Adresse mail'),
                  placeholder: const Text('mail@example.com'),
                  keyboardType: TextInputType.emailAddress,
                  prefix: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: ShadImage.square(size: 16, LucideIcons.mail),
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
                const SizedBox(height: 16),
                ShadButton(
                  onPressed: () {
                    if (formKey.currentState!.saveAndValidate()) {
                      logger.d('Validation succeeded with ${formKey.currentState!.value}');
                      Navigator.push(context, MaterialPageRoute(builder: (context) => OTPScreen(email: formKey.currentState!.value['email'],)));
                      logger.d('Signing in with email: ${formKey.currentState!.value['email']}');
                    } else {
                      logger.d('Validation failed');
                    }
                  },
                  child: const Text('Recevoir un code'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}