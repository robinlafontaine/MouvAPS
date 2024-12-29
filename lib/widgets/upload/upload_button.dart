import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mouvaps/services/upload.dart';

class UserUploadButton extends StatefulWidget {
  const UserUploadButton({super.key});

  @override
  State<UserUploadButton> createState() => _UserUploadButtonState();
}

class _UserUploadButtonState extends State<UserUploadButton> {
  late final UploadManager _uploadManager;
  final String _bucketName = 'user-data';
  List<UploadRequest> _uploadRequests = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _uploadManager = UploadManager(
      bucketName: _bucketName,
      onRequestsChanged: _handleRequestsChanged,
    );
  }

  void _handleRequestsChanged(List<UploadRequest> requests) {
    setState(() {
      _uploadRequests = requests;
      _isUploading = _uploadManager.isUploading;
    });
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(allowMultiple: true);
      if (result != null) {
        _uploadManager.addFiles(result.files);
      }
    } catch (e) {
      if (mounted) {
        _showErrorToast();
      }
    }
  }

  void _showErrorToast() {
    ShadToaster.of(context).show(
      ShadToast.destructive(
        title: const Text('Une erreur est survenue'),
        description: const Text('Impossible de sélectionner les fichiers'),
        action: ShadButton.destructive(
          child: const Text('OK'),
          onPressed: () => ShadToaster.of(context).hide(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_upload_outlined,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun fichier sélectionné',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileItem(int index, UploadRequest request) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(
            Icons.insert_drive_file,
            color: request.error != null ? Colors.red : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFileItemContent(request),
          ),
          if (!request.isUploading)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _uploadManager.removeFile(index),
            ),
        ],
      ),
    );
  }

  Widget _buildFileItemContent(UploadRequest request) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          request.fileName,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (request.isUploading)
          LinearProgressIndicator(
            value: request.progress,
            backgroundColor: Colors.grey[200],
          )
        else if (request.error != null)
          Text(
            request.error!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.red,
            ),
          ),
      ],
    );
  }

  Widget _buildFileList() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 300),
      child: ShadCard(
        child: SingleChildScrollView(
          child: Column(
            children: _uploadRequests.asMap().entries.map((entry) {
              return _buildFileItem(entry.key, entry.value);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text("En cours d'envoi..."),
      ],
    );
  }

  List<Widget> _buildActions() {
    return [
      ShadButton.outline(
        enabled: !_isUploading,
        onPressed: _pickFiles,
        child: const Text('Ajouter'),
      ),
      ShadButton(
        enabled: !_isUploading && _uploadRequests.isNotEmpty,
        onPressed: _uploadManager.uploadFiles,
        child: _isUploading
            ? _buildUploadingIndicator()
            : const Text('Envoyer'),
      ),
    ];
  }

  void _showUploadDialog() {
    //TODO: Manage dialog state changes. See https://github.com/flutter/flutter/issues/15194
    showShadDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, StateSetter setState) {
          return ShadDialog(
            title: const Text('Envoyer un fichier'),
            description: const Text(
              'Sélectionnez les fichiers que vous souhaitez envoyer',
            ),
            actions: _buildActions(),
            closeIcon: const Icon(Icons.close),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_uploadRequests.isEmpty)
                    _buildEmptyState()
                  else
                    _buildFileList(),
                ],
              ),
            ),
          );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShadButton(
      onPressed: () => _showUploadDialog(),
      icon: const Icon(Icons.cloud_upload_outlined),
      child: const Text('Envoyer Fichiers'),
    );
  }
}