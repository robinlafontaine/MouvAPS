import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mouvaps/home_screen.dart';
import 'package:pinput/pinput.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final SupabaseClient supabase = Supabase.instance.client;
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  String? errorMessage;
  bool isLoading = false;

  final String generatedOtp = '123456';

  @override
  void initState() {
    super.initState();
    _sendOtpToEmail();
  }

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Future<void> _sendOtpToEmail() async {
    await supabase.auth.signInWithOtp(email: widget.email);
    logger.d('OTP $generatedOtp sent to ${widget.email}');
  }

  Future<void> _verifyOtp() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final AuthResponse res = await supabase.auth.verifyOTP(
        type: OtpType.email,
        email: widget.email,
        token: pinController.text,
      );
      _onVerificationSuccess(res);
    } catch (e) {
      setState(() {
        errorMessage = 'Code invalide';
        isLoading = false;
      });
      return;
    }
  }

  void _onVerificationSuccess(AuthResponse res) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
  }

  void _resendOtp() {
    setState(() {
      errorMessage = null;
      isLoading = false;
    });

    _sendOtpToEmail();

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
      appBar: AppBar(
        title: const Text('Vérification'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              'Vérification par email',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Entrez le code de 6 chiffres envoyé à ${widget.email}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 40),
            Pinput(
              length: 6,
              controller: pinController,
              focusNode: focusNode,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration?.copyWith(
                  border: Border.all(color: Colors.blue),
                ),
              ),
              errorPinTheme: defaultPinTheme.copyWith(
                decoration: defaultPinTheme.decoration?.copyWith(
                  border: Border.all(color: Colors.red),
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
                  color: Colors.red,
                ),
              ),
            const SizedBox(height: 20),
            ShadButton(
              onPressed: _resendOtp,
              child: const Text('Renvoyer le code'),
            ),
          ],
        ),
      ),
    );
  }
}