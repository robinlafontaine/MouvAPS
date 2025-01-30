import 'dart:io';
import 'package:mime/mime.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadRequest {
  final File file;
  final String mimeType;
  final String fileName;
  bool isUploading;
  String? error;

  UploadRequest({
    required this.file,
    required this.fileName,
    this.isUploading = false,
    this.error,
  }) : mimeType = lookupMimeType(file.path) ?? '*/*';

  UploadRequest copyWith({
    bool? isUploading,
    String? error,
  }) {
    return UploadRequest(
      file: file,
      fileName: fileName,
      isUploading: isUploading ?? this.isUploading,
      error: error ?? this.error,
    );
  }
}

class UploadManager {
  final String bucketName;
  final SupabaseClient supabase = Supabase.instance.client;
  String? uploadedFileUrl;

  UploadRequest? _currentRequest;
  bool _isUploading = false;

  bool get isUploading => _isUploading;
  UploadRequest? get currentRequest => _currentRequest;

  UploadManager({
    required this.bucketName,
  });

  void setFile(PlatformFile file, String filePath) {
    _currentRequest = UploadRequest(
      file: File(file.path!),
      fileName: filePath,
    );
  }

  String getFile() {
    return _currentRequest!.file.path;
  }

  Future<String?> uploadFile() async {
    if (_currentRequest == null) {
      return null;
    }

    _isUploading = true;

    try {
      final response = await supabase.storage
          .from(bucketName)
          .upload(_currentRequest!.fileName, _currentRequest!.file);

      if (response.isEmpty) {
        return null;
      }

      final url = _getUploadedUrl(response);

      return url;
    } catch (e) {
      return null;
    } finally {
      _isUploading = false;
      _currentRequest = null;
    }
  }

  Future<String?> _getUploadedUrl(String filePath) async {
    final parsedFilePath = filePath.replaceFirst('$bucketName/', '');

    final response =
        supabase.storage.from(bucketName).getPublicUrl(parsedFilePath);

    if (response.isEmpty) {
      return null;
    }

    return response.replaceFirst('/public', '');
  }

  void clear() {
    _currentRequest = null;
    _isUploading = false;
  }
}
