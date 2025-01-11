import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:mouvaps/services/auth.dart';
import 'package:mouvaps/services/user.dart';
import 'package:mouvaps/utils/constants.dart' as constants;

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
    focusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _sendOtpToEmail() async {
    logger.d('Sending OTP to ${widget.email}');
    await Auth.instance.signInWithOtp(email: widget.email);
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

  Future<void> _verifyOtp(String pin) async {

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final bool res = await Auth.instance.verifyOtp(
      email: widget.email,
      token: pin,
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
    final uuid = Auth.instance.getUUID();
    User.exists(uuid).then((exists) {
      if (exists) {
        _onUserExists();
      } else {
        _onUserDoesNotExist();
      }
    });
  }

  _onUserExists() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/home',
      (route) => false,
    );
  }

  _onUserDoesNotExist() {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/form',
      (route) => false,
    );
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

  Widget _buildOTPInput() {
    return ShadInputOTP(
      onChanged: (v) => v.contains(' ') ? null : _verifyOtp(v),
      maxLength: 6,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      children: const [
        ShadInputOTPGroup(
          children: [
            ShadInputOTPSlot(),
            ShadInputOTPSlot(),
            ShadInputOTPSlot(),
          ],
        ),
        ShadImage.square(size: 24, LucideIcons.dot),
        ShadInputOTPGroup(
          children: [
            ShadInputOTPSlot(),
            ShadInputOTPSlot(),
            ShadInputOTPSlot(),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const ShadImage(
              'assets/images/icon.png',
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
              fontSize: constants.pFontSize,
              fontWeight: FontWeight.w400,
            ),),
            const SizedBox(height: 20),
            _buildOTPInput(),
            const SizedBox(height: 20),
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: constants.errorColor,
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