import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mouvaps/services/upload.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:mouvaps/utils/constants.dart' as constants;

class ContentUploadService {
  final String directoryPath;
  final FileType type;
  final VoidCallback? onUploadComplete;
  final UploadManager uploadManager;
  String? _uploadedFileUrl;

  String? get uploadedFileUrl => _uploadedFileUrl;

  ContentUploadService({
    required this.directoryPath,
    required this.type,
    this.onUploadComplete,
  }) : uploadManager = UploadManager(bucketName: 'media-content');

  Future<void> pickFile(BuildContext context,
      {FileType type = FileType.custom,
      List<String>? allowedExtensions}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: type,
      allowedExtensions: allowedExtensions,
      allowMultiple: false,
    );

    if (result != null) {
      final file = result.files.first;
      final String fullPath = '$directoryPath/${file.name}';

      uploadManager.setFile(file, fullPath);
      if (context.mounted) {
        Navigator.pop(context, true);
      }
    } else {
      if (context.mounted) {
        Navigator.pop(context, false);
      }
    }
  }

  Future<void> startUpload(BuildContext context) async {
    final response = await uploadManager.uploadFile();

    if (context.mounted) {
      if (response != null) {
        _uploadedFileUrl = response;
        onUploadComplete?.call();
      } else {
        ShadToaster.of(context).show(
          const ShadToast.destructive(
            title: Text('Mince !'),
            description: Text('Echec lors de l\'envoi du fichier'),
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
            leading: Icon(type.name == 'image' ? Icons.image : Icons.video_file,
                color: constants.primaryColor),
            title: Text('Envoyer une ${type.name}'),
            subtitle: Text('Choisissez une ${type.name} de votre appareil'),
            onTap: () => pickFile(context, type: type),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<String?> showUploadDialog(BuildContext context) async {
    final shouldUpload = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildModalSheet(context),
    );

    if (shouldUpload == true) {
      if (context.mounted) {
        return _uploadedFileUrl;
        /*await _startUpload(context);
        return _uploadedFileUrl;*/
      }
    }
    return null;
  }
}
