import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mouvaps/services/upload.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:mouvaps/utils/constants.dart' as constants;

class UserUploadButton extends StatefulWidget {
  final String? filename;
  final VoidCallback? onUploadComplete;

  const UserUploadButton({
    super.key,
    this.filename,
    this.onUploadComplete,
  });

  @override
  State<UserUploadButton> createState() => _UserUploadButtonState();
}

class _UserUploadButtonState extends State<UserUploadButton> {
  final UploadManager uploadManager = UploadManager(bucketName: 'user-data');
  bool _wasSuccessful = false;

  Future<void> _pickImage(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      uploadManager.setFile(result.files.first, widget.filename);
      if (context.mounted) {
        Navigator.pop(context);
      }
      _startUpload();
    }
  }

  Future<void> _pickFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );

    if (result != null) {
      uploadManager.setFile(result.files.first, widget.filename);
      if (context.mounted) {
        Navigator.pop(context);
      }
      _startUpload();
    }
  }

  Future<void> _startUpload() async {
    final bool response = await uploadManager.uploadFile();

    if (mounted) {
      setState(() {
        _wasSuccessful = response;
      });

      if (response) {
        widget.onUploadComplete?.call();
      } else {
        const ShadAlert.destructive(
            iconSrc: LucideIcons.circleAlert,
            title: Text('Erreur'),
            description: Text('Une erreur est survenue lors de l\'envoi du fichier'),
        );
      }
    }
  }

  Widget _buildModalSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'Envoyer un fichier',
            style: ShadTheme.of(context).textTheme.h2,
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.image, color: constants.primaryColor),
            title: const Text('Envoyer une Image'),
            subtitle: const Text('Choisissez une image de votre appareil'),
            onTap: () => _pickImage(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: constants.primaryColor),
            title: const Text('Envoyer un PDF'),
            subtitle: const Text('Choisissez un fichier PDF de votre appareil'),
            onTap: () => _pickFile(context),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShadButton(
      onPressed: _wasSuccessful
          ? null
          : () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => _buildModalSheet(context),
        );
      },
      enabled: !_wasSuccessful,
      icon: _wasSuccessful ? const Icon(Icons.check) : const Icon(Icons.cloud_upload),
      child: Text(_wasSuccessful ? 'Fichier envoyé' : 'Envoyer un fichier'),
    );
  }
}