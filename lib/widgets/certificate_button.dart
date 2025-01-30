import 'dart:io';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mouvaps/utils/constants.dart';
import 'package:open_filex/open_filex.dart';
import 'package:mouvaps/services/user.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CertificateButton extends StatefulWidget {
  final User user;

  const CertificateButton({super.key, required this.user});

  @override
  CertificateButtonState createState() => CertificateButtonState();
}

class CertificateButtonState extends State<CertificateButton> {
  bool hasCertificate = false;
  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();
    checkCertificate();
  }

  Future<void> checkCertificate() async {
    try {
      File? certificate = await widget.user.getCertificate();
      setState(() {
        hasCertificate = certificate != null;
      });
    } catch (e) {
      setState(() {
        hasCertificate = false;
      });
    }
  }

  Future<void> openCertificate() async {
    try {
      File? certificate = await widget.user.getCertificate();
      if (certificate == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Erreur : il n'y a pas de certificat"),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
      logger.d('Opening certificate ${certificate.path}');
      OpenFilex.open(certificate.path);
    } catch (e) {
      logger.e(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur : problème interne (${e.toString()})"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShadButton(
      onPressed: hasCertificate ? openCertificate : null,
      enabled: hasCertificate,
      child: const Text(
        "Consulter le certificat",
        style: TextStyle(
          color: Colors.white,
          fontSize: h4FontSize,
          fontVariations:[
            FontVariation(
                'wght', h4FontWeight
            )
          ],
        ),
      ),
    );
  }
}
