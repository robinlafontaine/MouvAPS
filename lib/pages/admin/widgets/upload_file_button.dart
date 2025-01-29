import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mouvaps/widgets/content_upload_service.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:mouvaps/utils/constants.dart';

class UploadFileButton extends StatelessWidget {
  final ContentUploadService contentUploadService;
  final VoidCallback onUpload;

  const UploadFileButton(
      {super.key, required this.contentUploadService, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return ShadButton(
      backgroundColor: Colors.white,
      decoration: const ShadDecoration(
        border: ShadBorder(
          top: ShadBorderSide(color: primaryColor, width: 2),
          bottom: ShadBorderSide(color: primaryColor, width: 2),
          left: ShadBorderSide(color: primaryColor, width: 2),
          right: ShadBorderSide(color: primaryColor, width: 2),
        ),
      ),
      size: ShadButtonSize.lg,
      child: const Icon(
        FontAwesomeIcons.image,
      ),
      onPressed: () async {
        await contentUploadService.showUploadDialog(context);
        onUpload();
      },
    );
  }
}
