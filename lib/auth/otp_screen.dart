import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pinput/pinput.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:mouvaps/utils/constants.dart' as Constants;

import '../services/auth.dart';

class OTPScreen extends StatefulWidget {

  final String email;

  const OTPScreen({
    super.key,
    required this.email
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  var logger = Logger(printer: SimplePrinter());
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  String? errorMessage;
  bool isLoading = false;
  bool isButtonDisabled = true;
  int countdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sendOtpToEmail();
    _startCountdown();
  }

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _sendOtpToEmail() async {
    logger.d('Sending OTP to ${widget.email}');
    await Auth().signInWithOtp(email: widget.email);
    logger.d('OTP sent to ${widget.email}');
  }

  void _startCountdown() {
    setState(() {
      isButtonDisabled = true;
      countdown = 60;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (countdown > 0) {
          countdown--;
        } else {
          isButtonDisabled = false;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _verifyOtp() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final bool res = await Auth().verifyOtp(
      email: widget.email,
      token: pinController.text,
    );

    if (!res) {
      setState(() {
        errorMessage = 'Code invalide';
        isLoading = false;
      });
      return;
    }

    _onVerificationSuccess(res);
  }

  void _onVerificationSuccess(bool res) {
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  void _resendOtp() {
    setState(() {
      errorMessage = null;
      isLoading = false;
    });

    _sendOtpToEmail();
    _startCountdown();

    ShadAlert(
      iconSrc: LucideIcons.send,
      title: const Text('Email envoyé'),
      description: Text('Nouveau code envoyé à ${widget.email}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const ShadImage(
              'https://avatars.githubusercontent.com/u/124599?v=4',
              height: 100,
            ),
            const SizedBox(height: 16),
            Text(
                'Vérification par email',
              style: ShadTheme.of(context).textTheme.h1
            ),
            const SizedBox(height: 16),
            Text('Veuillez entrer le code à 6 chiffres envoyé à ${widget.email}.',
            style: const TextStyle(
              fontSize: Constants.p_font_size,
              fontWeight: Constants.p_font_weight,
            ),),
            const SizedBox(height: 20),
            Pinput(
              length: 6,
              controller: pinController,
              focusNode: focusNode,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration?.copyWith(
                  border: Border.all(color: Constants.primary_color),
                ),
              ),
              errorPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration?.copyWith(
                  border: Border.all(color: Constants.error_color),
                ),
              ),
              errorText: errorMessage,
              onCompleted: (_) => _verifyOtp(),
            ),
            const SizedBox(height: 20),
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Constants.error_color,
                ),
              ),
            const SizedBox(height: 20),
            const Text("Vous n'avez pas reçu de mail ?"),
            const Text("Vérifiez vos spams et indésirables."),
            const SizedBox(height: 20),
            ShadButton(
              onPressed: _resendOtp,
              enabled: !isButtonDisabled,
              child: Text(isButtonDisabled ? 'Renvoyer le code ($countdown)' : 'Renvoyer le code'),
            ),
          ],
        ),
      ),
    );
  }
}