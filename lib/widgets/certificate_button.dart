import 'dart:io';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:open_filex/open_filex.dart';
import 'package:mouvaps/services/user.dart';

class CertificateButton extends StatelessWidget {
  final User user;

  const CertificateButton({super.key,
        required this.user
  });

  Future<void> openCertificate(BuildContext context, User user) async {
    Logger logger = Logger();
    try {
      File? certificate = await user.getCertificate();
      if (certificate == null) {
        if (context.mounted) {
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Erreur : $e"),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => openCertificate(context, user),
      child: const Text("Consulter le certificat"),
    );
  }
}