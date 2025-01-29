import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mouvaps/services/upload.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:mouvaps/services/auth.dart';
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

  Future<void> _pickFile(BuildContext context, {FileType type = FileType.custom, List<String>? allowedExtensions}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: type,
      allowedExtensions: allowedExtensions,
      allowMultiple: false,
    );

    if (result != null) {
      final file = result.files.first;
      final userFilepath = '${Auth.instance.getUUID()}/${widget.filename != null ? '${widget.filename}.${file.extension}' : file.name}';

      uploadManager.setFile(file, userFilepath);
      if (context.mounted) {
        Navigator.pop(context);
      }
      _startUpload();
    }
  }

  Future<void> _startUpload() async {
    final String? response = await uploadManager.uploadFile();

    if (mounted) {
      setState(() {
        _wasSuccessful = response != null;
      });

      if (response != null) {
        widget.onUploadComplete?.call();
      } else {
        ShadToaster.of(context).show(
          const ShadToast.destructive(
            title: Text('Mince !'),
            description:
            Text('Echec lors de l\'envoi du fichier'),
          ),
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
            onTap: () => _pickFile(context, type: FileType.image),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: constants.primaryColor),
            title: const Text('Envoyer un PDF'),
            subtitle: const Text('Choisissez un fichier PDF de votre appareil'),
            onTap: () => _pickFile(context, type: FileType.custom, allowedExtensions: ['pdf']),
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
      iconSize: const Size.square(24),
      child: Text(_wasSuccessful ? 'Fichier envoyé' : 'Envoyer un fichier'),
    );
  }
}